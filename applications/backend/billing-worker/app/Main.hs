module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Monad (forever)
import Data.Char (toLower)
import System.Environment (lookupEnv)
import System.IO
  ( BufferMode (LineBuffering),
    hSetBuffering,
    stderr,
    stdout,
  )

import BillingWorker.PullLoop (runPullLoop)

main :: IO ()
main = do
  hSetBuffering stdout LineBuffering
  hSetBuffering stderr LineBuffering
  productionMode <- resolveProductionMode
  if productionMode
    then runPullLoop
    else stableRunFallback

stableRunFallback :: IO ()
stableRunFallback = do
  putStrLn "[vocastock] billing-worker entered stable-run mode"
  forever $ do
    putStrLn "[vocastock] billing-worker awaiting queue/subscription work"
    threadDelay (30 * 1000000)

resolveProductionMode :: IO Bool
resolveProductionMode = do
  raw <- lookupEnv "VOCAS_PRODUCTION_ADAPTERS"
  pure $ case fmap (map toLower) raw of
    Just "true" -> True
    Just "1" -> True
    Just "yes" -> True
    _ -> False
