{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firestore emulator REST client (GET / POST / PATCH).
--
-- Paths are relative to `/v1/projects/{project}/databases/(default)/
-- documents/{rest}`. Clients craft the `{rest}` portion themselves.
module Vocas.Worker.Core.Firestore
  ( FirestoreClient (..),
    FirestoreError (..),
    firestoreFromEnv,
    newFirestoreClient,
    getDocument,
    createDocument,
    patchDocument,
    encodeStringField,
    encodeNullableStringField,
    encodeIntegerField,
    encodeMapField,
    encodeArrayField,
    encodeFieldsObject,
    readStringField,
    readNullableStringField,
    readIntegerField,
    readMapField,
    readArrayField,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import Data.Foldable (toList)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Read as TR
import Network.HTTP.Client.Conduit (Manager, Request (..))
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Header as Header
import qualified Network.HTTP.Types.Method as Method

import Vocas.Worker.Core.Env
  ( firestoreEmulatorHostEnv,
    resolveEmulatorHost,
    resolveProjectId,
  )
import Vocas.Worker.Core.Http
  ( HttpError (..),
    buildHttpManager,
    performJsonRequest,
  )

data FirestoreClient = FirestoreClient
  { firestoreHost :: Text,
    firestoreProject :: Text,
    firestoreManager :: Manager
  }

data FirestoreError
  = FirestoreTransport String
  | FirestoreHttpStatus Int
  | FirestoreInvalidResponse String
  deriving (Eq, Show)

firestoreFromEnv :: IO (Maybe FirestoreClient)
firestoreFromEnv = do
  host <- resolveEmulatorHost firestoreEmulatorHostEnv
  case host of
    Nothing -> pure Nothing
    Just resolved -> do
      project <- resolveProjectId
      manager <- buildHttpManager
      pure
        ( Just
            FirestoreClient
              { firestoreHost = T.pack resolved,
                firestoreProject = T.pack project,
                firestoreManager = manager
              }
        )

newFirestoreClient :: Text -> Text -> IO FirestoreClient
newFirestoreClient host project = do
  manager <- buildHttpManager
  pure
    FirestoreClient
      { firestoreHost = host,
        firestoreProject = project,
        firestoreManager = manager
      }

-- | Fetches a single document. Non-existent -> `Left (FirestoreHttpStatus 404)`.
getDocument :: FirestoreClient -> Text -> IO (Either FirestoreError Aeson.Value)
getDocument client relativePath = do
  request <- prepareRequest client Method.methodGet relativePath Nothing
  executeRequest client request

-- | Creates a document at `{collection}/{docId}` with the supplied
-- field map. 409 propagates to the caller; idempotent writers should
-- fall back to `patchDocument`.
createDocument ::
  FirestoreClient ->
  Text ->
  Text ->
  Aeson.Value ->
  IO (Either FirestoreError Aeson.Value)
createDocument client collectionPath docId fieldsObject = do
  let path =
        T.concat
          [ collectionPath,
            "?documentId=",
            percentEncodePath docId
          ]
  request <- prepareRequest client Method.methodPost path (Just fieldsObject)
  executeRequest client request

-- | Patches an existing document. `updateMaskPaths` supplies the
-- `updateMask.fieldPaths` query parameters; an empty list is treated
-- as "rewrite every field" which is rarely what you want.
patchDocument ::
  FirestoreClient ->
  Text ->
  [Text] ->
  Aeson.Value ->
  IO (Either FirestoreError Aeson.Value)
patchDocument client documentPath updateMaskPaths fieldsObject = do
  let maskQuery =
        T.intercalate "&" $
          fmap (\field -> "updateMask.fieldPaths=" <> percentEncodePath field) updateMaskPaths
  let path =
        if T.null maskQuery
          then documentPath
          else documentPath <> "?" <> maskQuery
  request <- prepareRequest client Method.methodPatch path (Just fieldsObject)
  executeRequest client request

prepareRequest ::
  FirestoreClient ->
  Method.Method ->
  Text ->
  Maybe Aeson.Value ->
  IO Request
prepareRequest client httpMethod relativePath payload = do
  let url =
        T.unpack ("http://" <> firestoreHost client)
          <> T.unpack
            ( T.concat
                [ "/v1/projects/",
                  firestoreProject client,
                  "/databases/(default)/documents/",
                  relativePath
                ]
            )
  initial <- Http.parseRequest url
  let base =
        initial
          { method = httpMethod,
            requestHeaders =
              [ (Header.hAccept, "application/json"),
                (Header.hContentType, "application/json; charset=utf-8")
              ]
          }
  pure $ case payload of
    Nothing -> base
    Just value -> base {requestBody = Http.RequestBodyLBS (Aeson.encode value)}

executeRequest ::
  FirestoreClient ->
  Request ->
  IO (Either FirestoreError Aeson.Value)
executeRequest client request = do
  outcome <- performJsonRequest (firestoreManager client) request
  pure $ case outcome of
    Left (TransportError msg) -> Left (FirestoreTransport msg)
    Left (HttpStatusError code _) -> Left (FirestoreHttpStatus code)
    Left (InvalidResponseError msg) -> Left (FirestoreInvalidResponse msg)
    Right value -> Right value

-- ---------- Field encoders (Rust side parity) -------------------------

encodeStringField :: Text -> Aeson.Value
encodeStringField value = Aeson.object [Key.fromText "stringValue" Aeson..= value]

encodeNullableStringField :: Maybe Text -> Aeson.Value
encodeNullableStringField Nothing = Aeson.object [Key.fromText "nullValue" Aeson..= Aeson.Null]
encodeNullableStringField (Just value) = encodeStringField value

encodeIntegerField :: Integer -> Aeson.Value
encodeIntegerField value = Aeson.object [Key.fromText "integerValue" Aeson..= show value]

encodeMapField :: [(Text, Aeson.Value)] -> Aeson.Value
encodeMapField entries =
  Aeson.object
    [ Key.fromText "mapValue"
        Aeson..= Aeson.object
          [ Key.fromText "fields"
              Aeson..= Aeson.object
                [Key.fromText key Aeson..= value | (key, value) <- entries]
          ]
    ]

encodeArrayField :: [Aeson.Value] -> Aeson.Value
encodeArrayField entries =
  Aeson.object
    [ Key.fromText "arrayValue"
        Aeson..= Aeson.object [Key.fromText "values" Aeson..= entries]
    ]

-- | Wraps `{ "fields": { ... } }` for POST / PATCH payloads.
encodeFieldsObject :: [(Text, Aeson.Value)] -> Aeson.Value
encodeFieldsObject entries =
  Aeson.object
    [ Key.fromText "fields"
        Aeson..= Aeson.object [Key.fromText key Aeson..= value | (key, value) <- entries]
    ]

-- ---------- Field readers (mirror of Rust shared-firestore::value) ----

readStringField :: Aeson.Value -> Text -> Maybe Text
readStringField (Aeson.Object obj) key =
  case KeyMap.lookup (Key.fromText key) obj of
    Just (Aeson.Object wrapper) ->
      case KeyMap.lookup (Key.fromText "stringValue") wrapper of
        Just (Aeson.String value) -> Just value
        _ -> Nothing
    _ -> Nothing
readStringField _ _ = Nothing

readNullableStringField :: Aeson.Value -> Text -> Maybe (Maybe Text)
readNullableStringField (Aeson.Object obj) key =
  case KeyMap.lookup (Key.fromText key) obj of
    Just (Aeson.Object wrapper)
      | KeyMap.member (Key.fromText "nullValue") wrapper -> Just Nothing
      | otherwise -> case KeyMap.lookup (Key.fromText "stringValue") wrapper of
          Just (Aeson.String value) -> Just (Just value)
          _ -> Nothing
    _ -> Nothing
readNullableStringField _ _ = Nothing

readIntegerField :: Aeson.Value -> Text -> Maybe Integer
readIntegerField (Aeson.Object obj) key =
  case KeyMap.lookup (Key.fromText key) obj of
    Just (Aeson.Object wrapper) ->
      case KeyMap.lookup (Key.fromText "integerValue") wrapper of
        Just (Aeson.String raw) -> case TR.signed TR.decimal raw of
          Right (value, "") -> Just value
          _ -> Nothing
        Just (Aeson.Number n) -> Just (round n)
        _ -> Nothing
    _ -> Nothing
readIntegerField _ _ = Nothing

readMapField :: Aeson.Value -> Text -> Maybe Aeson.Value
readMapField (Aeson.Object obj) key =
  case KeyMap.lookup (Key.fromText key) obj of
    Just (Aeson.Object wrapper) ->
      case KeyMap.lookup (Key.fromText "mapValue") wrapper of
        Just (Aeson.Object mapEnvelope) ->
          case KeyMap.lookup (Key.fromText "fields") mapEnvelope of
            Just fieldsValue -> Just fieldsValue
            _ -> Nothing
        _ -> Nothing
    _ -> Nothing
readMapField _ _ = Nothing

readArrayField :: Aeson.Value -> Text -> Maybe [Aeson.Value]
readArrayField (Aeson.Object obj) key =
  case KeyMap.lookup (Key.fromText key) obj of
    Just (Aeson.Object wrapper) ->
      case KeyMap.lookup (Key.fromText "arrayValue") wrapper of
        Just (Aeson.Object arrEnvelope) ->
          case KeyMap.lookup (Key.fromText "values") arrEnvelope of
            Just (Aeson.Array values) -> Just (toList values)
            _ -> Nothing
        _ -> Nothing
    _ -> Nothing
readArrayField _ _ = Nothing

percentEncodePath :: Text -> Text
percentEncodePath raw = T.pack (concatMap encodeChar (T.unpack raw))
  where
    encodeChar c
      | isUnreserved c = [c]
      | otherwise = '%' : hex2 (fromEnum c)
    isUnreserved c =
      (c >= 'A' && c <= 'Z')
        || (c >= 'a' && c <= 'z')
        || (c >= '0' && c <= '9')
        || c == '-'
        || c == '_'
        || c == '.'
        || c == '~'
    hex2 n =
      let digit v = "0123456789ABCDEF" !! v
       in [digit (n `div` 16), digit (n `mod` 16)]

_reservedMap :: Map.Map Text Text
_reservedMap = Map.empty
