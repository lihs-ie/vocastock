{-# LANGUAGE OverloadedStrings #-}

-- |
-- PubSub emulator REST client (pull / acknowledge).
--
-- The emulator accepts the standard Google PubSub REST surface, so
-- production (`pubsub.googleapis.com`) can share the same code once
-- the `PUBSUB_EMULATOR_HOST` override is not set. For now we only
-- support the emulator form (`http://{host}/v1/...`).
module Vocas.Worker.Core.PubSub
  ( PubSubClient (..),
    ReceivedMessage (..),
    pubsubFromEnv,
    newPubSubClient,
    pullMessages,
    acknowledge,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as Base64
import qualified Data.ByteString.Lazy as LBS
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Network.HTTP.Client.Conduit (Manager, Request (..))
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Header as Header
import qualified Network.HTTP.Types.Method as Method

import Vocas.Worker.Core.Env
  ( defaultProjectId,
    pubsubEmulatorHostEnv,
    resolveEmulatorHost,
    resolveProjectId,
  )
import Vocas.Worker.Core.Http (HttpError (..), buildHttpManager, performJsonRequest)

data PubSubClient = PubSubClient
  { pubsubHost :: Text,
    pubsubProject :: Text,
    pubsubManager :: Manager
  }

data ReceivedMessage = ReceivedMessage
  { receivedAckId :: Text,
    receivedMessageId :: Text,
    receivedAttributes :: Map Text Text,
    receivedData :: LBS.ByteString
  }
  deriving (Eq, Show)

-- | Constructs a client from environment variables, or returns
-- `Nothing` when `PUBSUB_EMULATOR_HOST` is unset / empty.
pubsubFromEnv :: IO (Maybe PubSubClient)
pubsubFromEnv = do
  host <- resolveEmulatorHost pubsubEmulatorHostEnv
  case host of
    Nothing -> pure Nothing
    Just resolved -> do
      project <- resolveProjectId
      manager <- buildHttpManager
      pure
        ( Just
            PubSubClient
              { pubsubHost = T.pack resolved,
                pubsubProject = T.pack project,
                pubsubManager = manager
              }
        )
{-# INLINE defaultProjectIdPinned #-}
defaultProjectIdPinned :: String
defaultProjectIdPinned = defaultProjectId

-- | Useful for feature tests that want to inject their own host /
-- project without going through the environment.
newPubSubClient :: Text -> Text -> IO PubSubClient
newPubSubClient host project = do
  manager <- buildHttpManager
  pure
    PubSubClient
      { pubsubHost = host,
        pubsubProject = project,
        pubsubManager = manager
      }

-- | Pulls up to `maxMessages` messages from the subscription. Returns
-- an empty list when the subscription is empty or on transport errors
-- (errors are logged by the caller's run loop; a transient failure
-- just means "try again on the next tick").
pullMessages :: PubSubClient -> Text -> Int -> IO [ReceivedMessage]
pullMessages client subscription maxMessages = do
  let path =
        T.concat
          [ "/v1/projects/",
            pubsubProject client,
            "/subscriptions/",
            subscription,
            ":pull"
          ]
  let body =
        Aeson.object
          [ Key.fromText "maxMessages" Aeson..= maxMessages,
            Key.fromText "returnImmediately" Aeson..= True
          ]
  request <- prepareJsonRequest client path body
  outcome <- performJsonRequest (pubsubManager client) request
  case outcome of
    Left _ -> pure []
    Right value -> pure (parseReceivedMessages value)

-- | Best-effort acknowledge of a batch of `ackId`s. Errors are swallowed
-- so the run loop keeps going; emulator redelivers messages whose ack
-- fails.
acknowledge :: PubSubClient -> Text -> [Text] -> IO ()
acknowledge _ _ [] = pure ()
acknowledge client subscription ackIds = do
  let path =
        T.concat
          [ "/v1/projects/",
            pubsubProject client,
            "/subscriptions/",
            subscription,
            ":acknowledge"
          ]
  let body = Aeson.object [Key.fromText "ackIds" Aeson..= ackIds]
  request <- prepareJsonRequest client path body
  _ <- performJsonRequest (pubsubManager client) request
  pure ()

prepareJsonRequest :: PubSubClient -> Text -> Aeson.Value -> IO Request
prepareJsonRequest client path body = do
  let url = T.unpack ("http://" <> pubsubHost client) <> T.unpack path
  initial <- Http.parseRequest url
  pure
    initial
      { method = Method.methodPost,
        requestHeaders =
          [ (Header.hContentType, "application/json; charset=utf-8"),
            (Header.hAccept, "application/json")
          ],
        requestBody = Http.RequestBodyLBS (Aeson.encode body)
      }

parseReceivedMessages :: Aeson.Value -> [ReceivedMessage]
parseReceivedMessages value =
  case value of
    Aeson.Object obj ->
      case KeyMap.lookup (Key.fromText "receivedMessages") obj of
        Just (Aeson.Array entries) ->
          foldr
            ( \entry acc -> case parseReceivedMessage entry of
                Just message -> message : acc
                Nothing -> acc
            )
            []
            entries
        _ -> []
    _ -> []

parseReceivedMessage :: Aeson.Value -> Maybe ReceivedMessage
parseReceivedMessage (Aeson.Object obj) = do
  ack <- lookupText "ackId" obj
  messageValue <- KeyMap.lookup (Key.fromText "message") obj
  case messageValue of
    Aeson.Object messageObj -> do
      messageId <- lookupText "messageId" messageObj
      let attributes = parseAttributes messageObj
      let body = parseMessageData messageObj
      pure
        ReceivedMessage
          { receivedAckId = ack,
            receivedMessageId = messageId,
            receivedAttributes = attributes,
            receivedData = body
          }
    _ -> Nothing
parseReceivedMessage _ = Nothing

parseAttributes :: KeyMap.KeyMap Aeson.Value -> Map Text Text
parseAttributes messageObj =
  case KeyMap.lookup (Key.fromText "attributes") messageObj of
    Just (Aeson.Object attrs) ->
      Map.fromList $
        [ (Key.toText key, value)
        | (key, Aeson.String value) <- KeyMap.toList attrs
        ]
    _ -> Map.empty

parseMessageData :: KeyMap.KeyMap Aeson.Value -> LBS.ByteString
parseMessageData messageObj =
  case KeyMap.lookup (Key.fromText "data") messageObj of
    Just (Aeson.String encoded) ->
      case Base64.decode (TE.encodeUtf8 encoded) of
        Right bytes -> LBS.fromStrict bytes
        Left _ -> LBS.empty
    _ -> LBS.empty

lookupText :: Text -> KeyMap.KeyMap Aeson.Value -> Maybe Text
lookupText key obj = case KeyMap.lookup (Key.fromText key) obj of
  Just (Aeson.String value) -> Just value
  _ -> Nothing

_reservedHttpError :: HttpError
_reservedHttpError = InvalidResponseError ""

_reservedByteString :: BS.ByteString
_reservedByteString = BS.empty

_reservedProjectPinned :: String
_reservedProjectPinned = defaultProjectIdPinned
