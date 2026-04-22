-- |
-- Environment-variable helpers used by the worker adapters.
--
-- The worker stack mirrors the Rust side's `VOCAS_PRODUCTION_ADAPTERS`
-- contract: unset/false means the worker runs in skeleton mode and
-- must not publish/read from emulators, true means the Firestore /
-- PubSub / Storage clients are required.
module Vocas.Worker.Core.Env
  ( firestoreEmulatorHostEnv,
    pubsubEmulatorHostEnv,
    storageEmulatorHostEnv,
    firebaseProjectEnv,
    productionAdaptersEnv,
    defaultProjectId,
    productionAdaptersEnabled,
    resolveProjectId,
    resolveEmulatorHost,
    resolveBaseUrl,
    lookupRequiredEnv,
  )
where

import Data.Char (toLower)
import Data.Maybe (fromMaybe)
import System.Environment (lookupEnv)

firestoreEmulatorHostEnv :: String
firestoreEmulatorHostEnv = "FIRESTORE_EMULATOR_HOST"

pubsubEmulatorHostEnv :: String
pubsubEmulatorHostEnv = "PUBSUB_EMULATOR_HOST"

storageEmulatorHostEnv :: String
storageEmulatorHostEnv = "STORAGE_EMULATOR_HOST"

firebaseProjectEnv :: String
firebaseProjectEnv = "FIREBASE_PROJECT"

productionAdaptersEnv :: String
productionAdaptersEnv = "VOCAS_PRODUCTION_ADAPTERS"

defaultProjectId :: String
defaultProjectId = "demo-vocastock"

-- | True when `VOCAS_PRODUCTION_ADAPTERS` is set to one of
-- `true` / `1` / `yes`. Matches the Rust-side helper exactly so the
-- contract stays consistent across services.
productionAdaptersEnabled :: IO Bool
productionAdaptersEnabled = do
  raw <- lookupEnv productionAdaptersEnv
  pure $ case fmap (map toLower) raw of
    Just "true" -> True
    Just "1" -> True
    Just "yes" -> True
    _ -> False

resolveProjectId :: IO String
resolveProjectId = do
  raw <- lookupEnv firebaseProjectEnv
  pure (fromMaybe defaultProjectId (nonEmpty raw))

-- | Reads `{name}` as `host:port`, stripping whitespace; returns
-- `Nothing` when unset or empty.
resolveEmulatorHost :: String -> IO (Maybe String)
resolveEmulatorHost name = do
  raw <- lookupEnv name
  pure (nonEmpty (fmap stripSpaces raw))

-- | For external APIs (Anthropic / Stability / Stripe) the override env
-- var (e.g. `ANTHROPIC_API_BASE_URL`) lets feature tests point at a
-- local fixture server. When unset we return the supplied canonical
-- URL.
resolveBaseUrl :: String -> String -> IO String
resolveBaseUrl overrideEnv defaultUrl = do
  raw <- lookupEnv overrideEnv
  pure (fromMaybe defaultUrl (nonEmpty (fmap stripSpaces raw)))

-- | Reads an env var that must be set (e.g. `ANTHROPIC_API_KEY` in
-- production). Returns `Left name` when missing.
lookupRequiredEnv :: String -> IO (Either String String)
lookupRequiredEnv name = do
  raw <- lookupEnv name
  pure $ case nonEmpty (fmap stripSpaces raw) of
    Just value -> Right value
    Nothing -> Left name

stripSpaces :: String -> String
stripSpaces = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse

nonEmpty :: Maybe String -> Maybe String
nonEmpty (Just s) | not (null s) = Just s
nonEmpty _ = Nothing
