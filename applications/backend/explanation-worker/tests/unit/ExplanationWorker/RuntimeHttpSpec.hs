module ExplanationWorker.RuntimeHttpSpec (run) where

import Control.Concurrent (killThread, threadDelay)
import Data.Aeson (decode)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as Text
import ExplanationWorker.RuntimeHttp
import Network.HTTP.Types (status200, status404)
import Network.Wai (Application, defaultRequest, pathInfo, rawPathInfo, requestMethod)
import Network.Wai.Test
  ( SRequest (..),
    SResponse,
    Session,
    runSession,
    simpleBody,
    simpleStatus,
    srequest
  )
import TestSupport

run :: IO ()
run = do
  runNamed "reports internal route catalog" testRouteCatalog
  runNamed "reports ready payload" testReadyPayload
  runNamed "reports validation payload for known scenarios" testValidationPayload
  runNamed "rejects unknown validation scenarios" testUnknownScenario
  runNamed "parses internal http enable flag" testInternalHttpEnabled
  runNamed "parses internal http port" testInternalHttpPort
  runNamed "starts the internal runtime server" testStartInternalRuntimeServer
  runNamed "covers payload accessors and show instances" testAccessorsAndShow

testRouteCatalog :: IO ()
testRouteCatalog = do
  response <- runRequest "/internal/routes"
  assertEqual "route status" status200 (simpleStatus response)
  assertEqual
    "route payload"
    (Just (InternalRouteCatalogPayload internalRouteCatalog))
    (decode (simpleBody response) :: Maybe InternalRouteCatalogPayload)

testReadyPayload :: IO ()
testReadyPayload = do
  response <- runRequest "/internal/readyz"
  assertEqual "ready status" status200 (simpleStatus response)
  assertEqual
    "ready payload"
    (Just (InternalReadyPayload "explanation-worker" "internal-only-servant"))
    (decode (simpleBody response) :: Maybe InternalReadyPayload)

testValidationPayload :: IO ()
testValidationPayload = do
  response <- runRequest "/internal/validation/success"
  assertEqual "validation status" status200 (simpleStatus response)
  let decoded = decode (simpleBody response) :: Maybe InternalValidationPayload
  assertEqual
    "validation payload"
    ( Just
        InternalValidationPayload
          { validationScenario = "success",
            validationFinalState = "succeeded",
            validationVisibility = "completed-current",
            validationFailureCode = "none",
            validationRenderedReport =
              "VOCAS_EXPLANATION_RESULT scenario=success final_state=succeeded trail=queued,running,succeeded visibility=completed-current failure_code=none retryable=false completed_saved=true handoff_completed=true current_action=switched current_retained=false duplicate=fresh"
          }
    )
    decoded

testUnknownScenario :: IO ()
testUnknownScenario = do
  response <- runRequest "/internal/validation/not-found"
  assertEqual "unknown scenario status" status404 (simpleStatus response)

testInternalHttpEnabled :: IO ()
testInternalHttpEnabled = do
  assertEqual "enabled flag true" True (internalHttpEnabled (Just "true"))
  assertEqual "enabled flag trimmed" True (internalHttpEnabled (Just " YES "))
  assertEqual "enabled flag false" False (internalHttpEnabled (Just "false"))
  assertEqual "enabled flag missing" False (internalHttpEnabled Nothing)

testInternalHttpPort :: IO ()
testInternalHttpPort = do
  assertEqual "explicit port" 40123 (internalHttpPort (Just "40123"))
  assertEqual "invalid port falls back" 39090 (internalHttpPort (Just "abc"))
  assertEqual "missing port falls back" 39090 (internalHttpPort Nothing)

testStartInternalRuntimeServer :: IO ()
testStartInternalRuntimeServer = do
  threadIdentifier <- startInternalRuntimeServer "explanation-worker" 0
  threadDelay 100000
  killThread threadIdentifier

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  let readyPayload = InternalReadyPayload "explanation-worker" "internal-only-servant"
      routePayload = InternalRouteCatalogPayload internalRouteCatalog
      validationPayload =
        InternalValidationPayload
          { validationScenario = "success",
            validationFinalState = "succeeded",
            validationVisibility = "completed-current",
            validationFailureCode = "none",
            validationRenderedReport = "report"
          }
  assertEqual "ready service accessor" "explanation-worker" (readyService readyPayload)
  assertEqual "ready surface accessor" "internal-only-servant" (readySurface readyPayload)
  assertEqual "route accessor" internalRouteCatalog (routeCatalog routePayload)
  assertEqual "validation scenario accessor" "success" (validationScenario validationPayload)
  assertEqual "validation final state accessor" "succeeded" (validationFinalState validationPayload)
  assertEqual "validation visibility accessor" "completed-current" (validationVisibility validationPayload)
  assertEqual "validation failure accessor" "none" (validationFailureCode validationPayload)
  assertEqual "validation rendered accessor" "report" (validationRenderedReport validationPayload)
  assertEqual "ready payload equality" True (readyPayload == readyPayload)
  assertEqual "route payload equality" True (routePayload == routePayload)
  assertEqual "validation payload equality" True (validationPayload == validationPayload)
  assertTrue "show ready payload" ("InternalReadyPayload" `elem` words (show readyPayload))
  assertTrue "show route payload" ("InternalRouteCatalogPayload" `elem` words (show routePayload))
  assertTrue "show validation payload" ("InternalValidationPayload" `elem` words (show validationPayload))

runRequest :: String -> IO SResponse
runRequest pathValue =
  runSession (issueGet pathValue) testApplication

issueGet :: String -> Session SResponse
issueGet pathValue =
  srequest $
    SRequest
      defaultRequest
        { requestMethod = BS8.pack "GET",
          rawPathInfo = BS8.pack pathValue,
          pathInfo = map Text.pack (filter (not . null) (splitPath pathValue))
        }
      LBS.empty

testApplication :: Application
testApplication = internalRuntimeApplication "explanation-worker"

splitPath :: String -> [String]
splitPath raw =
  case dropWhile (== '/') raw of
    "" -> []
    trimmed ->
      let (segment, rest) = break (== '/') trimmed
       in segment : splitPath rest
