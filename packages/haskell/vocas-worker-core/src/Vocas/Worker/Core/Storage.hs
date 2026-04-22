{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firebase Storage emulator REST upload client.
--
-- The emulator exposes an HTTP-1.1 surface at
-- `http://{host}/v0/b/{bucket}/o?name={path}&uploadType=media`. For
-- `image-worker`, a single upload per generation is enough; larger
-- binaries (resumable uploads) are out of scope.
module Vocas.Worker.Core.Storage
  ( StorageClient (..),
    StorageError (..),
    storageFromEnv,
    newStorageClient,
    uploadObject,
  )
where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text as T
import Data.Text (Text)
import Network.HTTP.Client.Conduit (Manager, Request (..))
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Header as Header
import qualified Network.HTTP.Types.Method as Method

import Vocas.Worker.Core.Env
  ( resolveEmulatorHost,
    storageEmulatorHostEnv,
  )
import Vocas.Worker.Core.Http
  ( HttpError (..),
    buildHttpManager,
    performRawRequest,
  )

data StorageClient = StorageClient
  { storageHost :: Text,
    storageManager :: Manager
  }

data StorageError
  = StorageTransport String
  | StorageHttpStatus Int
  deriving (Eq, Show)

storageFromEnv :: IO (Maybe StorageClient)
storageFromEnv = do
  host <- resolveEmulatorHost storageEmulatorHostEnv
  case host of
    Nothing -> pure Nothing
    Just resolved -> do
      manager <- buildHttpManager
      pure
        ( Just
            StorageClient
              { storageHost = T.pack resolved,
                storageManager = manager
              }
        )

newStorageClient :: Text -> IO StorageClient
newStorageClient host = do
  manager <- buildHttpManager
  pure
    StorageClient
      { storageHost = host,
        storageManager = manager
      }

-- | PUTs the supplied bytes to `{bucket}/{objectPath}`. Returns the
-- `objectPath` (i.e. the assetReference Firestore stores) on success.
uploadObject ::
  StorageClient ->
  Text ->
  Text ->
  BS.ByteString ->
  BS.ByteString ->
  IO (Either StorageError Text)
uploadObject client bucket objectPath contentType bytes = do
  let url =
        T.unpack ("http://" <> storageHost client)
          <> "/v0/b/"
          <> T.unpack bucket
          <> "/o?uploadType=media&name="
          <> T.unpack (percentEncodePath objectPath)
  initial <- Http.parseRequest url
  let request =
        initial
          { method = Method.methodPost,
            requestHeaders = [(Header.hContentType, contentType)],
            requestBody = Http.RequestBodyBS bytes
          }
  outcome <- performRawRequest (storageManager client) request
  pure $ case outcome of
    Left (TransportError msg) -> Left (StorageTransport msg)
    Left (HttpStatusError code _) -> Left (StorageHttpStatus code)
    Left (InvalidResponseError msg) -> Left (StorageTransport msg)
    Right _ -> Right objectPath

percentEncodePath :: Text -> Text
percentEncodePath raw = T.pack (concatMap encodeChar (T.unpack raw))
  where
    encodeChar c
      | isUnreserved c = [c]
      | c == '/' = "%2F"
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

_reservedBytes :: BS.ByteString
_reservedBytes = BS8.empty
