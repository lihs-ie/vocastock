-- |
-- Thin wrapper over `http-conduit` with consistent error mapping for
-- Firestore / PubSub / external LLM + billing adapters. We expose a
-- single `HttpError` type so caller code can branch on transport vs
-- server-side failures without touching `HttpException`.
module Vocas.Worker.Core.Http
  ( HttpError (..),
    HttpResponseBody,
    buildHttpManager,
    performJsonRequest,
    performRawRequest,
  )
where

import Control.Exception (SomeException, try)
import Data.Aeson (Value, decode)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS
import Network.HTTP.Client.Conduit (Manager, Request (..), Response (..))
import qualified Network.HTTP.Conduit as Http
import qualified Network.HTTP.Types.Status as Status

type HttpResponseBody = LBS.ByteString

data HttpError
  = TransportError String
  | HttpStatusError Int HttpResponseBody
  | InvalidResponseError String
  deriving (Show, Eq)

buildHttpManager :: IO Manager
buildHttpManager = Http.newManager Http.tlsManagerSettings

-- | Executes a prepared `http-conduit` request and returns the raw body.
-- 2xx -> `Right body`. Non-2xx -> `Left (HttpStatusError code body)`.
-- Network / DNS failures -> `Left (TransportError msg)`.
performRawRequest :: Manager -> Request -> IO (Either HttpError HttpResponseBody)
performRawRequest manager request = do
  result <- try (Http.httpLbs request manager) :: IO (Either SomeException (Response LBS.ByteString))
  case result of
    Left exception -> pure (Left (TransportError (show exception)))
    Right response ->
      let code = Status.statusCode (responseStatus response)
          body = responseBody response
       in if code >= 200 && code < 300
            then pure (Right body)
            else pure (Left (HttpStatusError code body))

-- | Convenience wrapper: executes the request and attempts to decode
-- the body as JSON. Returns `InvalidResponseError` when the body is not
-- valid JSON, otherwise the decoded `Value`.
performJsonRequest :: Manager -> Request -> IO (Either HttpError Value)
performJsonRequest manager request = do
  outcome <- performRawRequest manager request
  pure $ case outcome of
    Left err -> Left err
    Right body -> case decode body of
      Just value -> Right value
      Nothing ->
        Left
          ( InvalidResponseError
              ("unable to decode response body as JSON: " <> show (LBS.take 200 body))
          )

-- keep ByteString re-export reachable without exposing implementation
_reservedByteString :: BS.ByteString
_reservedByteString = BS.empty
