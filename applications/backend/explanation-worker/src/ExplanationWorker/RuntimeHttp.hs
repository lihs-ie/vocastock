{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module ExplanationWorker.RuntimeHttp
  ( InternalReadyPayload (..),
    InternalRouteCatalogPayload (..),
    InternalValidationPayload (..),
    internalHttpEnabled,
    internalHttpPort,
    internalRouteCatalog,
    internalRuntimeApplication,
    startInternalRuntimeServer
  )
where

import Control.Concurrent (ThreadId, forkIO)
import Data.Aeson (FromJSON, ToJSON)
import Data.Char (toLower)
import GHC.Generics (Generic)
import Network.Wai (Application)
import Network.Wai.Handler.Warp
  ( defaultSettings,
    runSettings,
    setBeforeMainLoop,
    setHost,
    setPort
  )
import Servant

import ExplanationWorker.WorkerRuntime
  ( WorkerScenario,
    parseWorkerScenarioLabel,
    renderScenarioReport,
    reportFailureCode,
    reportFinalState,
    reportScenario,
    reportVisibility,
    runScenarioReport
  )

data InternalReadyPayload = InternalReadyPayload
  { readyService :: String,
    readySurface :: String
  }
  deriving (Eq, Generic, Show)

instance ToJSON InternalReadyPayload

instance FromJSON InternalReadyPayload

data InternalRouteCatalogPayload = InternalRouteCatalogPayload
  { routeCatalog :: [String]
  }
  deriving (Eq, Generic, Show)

instance ToJSON InternalRouteCatalogPayload

instance FromJSON InternalRouteCatalogPayload

data InternalValidationPayload = InternalValidationPayload
  { validationScenario :: String,
    validationFinalState :: String,
    validationVisibility :: String,
    validationFailureCode :: String,
    validationRenderedReport :: String
  }
  deriving (Eq, Generic, Show)

instance ToJSON InternalValidationPayload

instance FromJSON InternalValidationPayload

type InternalRuntimeApi =
  "internal" :> "readyz" :> Get '[JSON] InternalReadyPayload
    :<|> "internal" :> "routes" :> Get '[JSON] InternalRouteCatalogPayload
    :<|> "internal" :> "validation" :> Capture "scenario" String :> Get '[JSON] InternalValidationPayload

internalRouteCatalog :: [String]
internalRouteCatalog =
  [ "/internal/readyz",
    "/internal/routes",
    "/internal/validation/:scenario"
  ]

internalHttpEnabled :: Maybe String -> Bool
internalHttpEnabled maybeValue =
  maybe False isEnabled maybeValue
  where
    isEnabled rawValue =
      map toLower (trim rawValue) `elem` ["1", "true", "yes", "on"]

internalHttpPort :: Maybe String -> Int
internalHttpPort maybeValue =
  case maybeValue >>= readMaybeInt of
    Just parsed -> parsed
    Nothing -> 39090

internalRuntimeApplication :: String -> Application
internalRuntimeApplication serviceName =
  serve internalRuntimeApiProxy (internalRuntimeServer serviceName)

startInternalRuntimeServer :: String -> Int -> IO ThreadId
startInternalRuntimeServer serviceName port =
  forkIO $
    runSettings
      ( setBeforeMainLoop
          ( putStrLn
              ("[vocastock] " ++ serviceName ++ " internal http adapter ready on port " ++ show port)
          )
          . setHost "127.0.0.1"
          . setPort port
          $ defaultSettings
      )
      (internalRuntimeApplication serviceName)

internalRuntimeApiProxy :: Proxy InternalRuntimeApi
internalRuntimeApiProxy = Proxy

internalRuntimeServer ::
  String ->
  Server InternalRuntimeApi
internalRuntimeServer serviceName =
  pure (InternalReadyPayload serviceName "internal-only-servant")
    :<|> pure (InternalRouteCatalogPayload internalRouteCatalog)
    :<|> renderValidationScenario

renderValidationScenario :: String -> Handler InternalValidationPayload
renderValidationScenario scenarioLabel =
  case parseWorkerScenario scenarioLabel of
    Nothing -> throwError err404
    Just scenario ->
      let report = runScenarioReport scenario
       in pure
            InternalValidationPayload
              { validationScenario = reportScenario report,
                validationFinalState = reportFinalState report,
                validationVisibility = reportVisibility report,
                validationFailureCode = reportFailureCode report,
                validationRenderedReport = renderScenarioReport report
              }

parseWorkerScenario :: String -> Maybe WorkerScenario
parseWorkerScenario = parseWorkerScenarioLabel

readMaybeInt :: String -> Maybe Int
readMaybeInt rawValue =
  case reads rawValue of
    [(parsed, "")] -> Just parsed
    _ -> Nothing

trim :: String -> String
trim = trimRight . trimLeft
  where
    trimLeft = dropWhile (`elem` [' ', '\t'])
    trimRight = reverse . trimLeft . reverse
