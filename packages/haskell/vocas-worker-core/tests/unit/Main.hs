module Main (main) where

import qualified EnvSpec
import qualified FirestoreSpec
import qualified MessageEnvelopeSpec
import System.Exit (exitFailure, exitSuccess)

main :: IO ()
main = do
  results <-
    sequence
      [ EnvSpec.run,
        MessageEnvelopeSpec.run,
        FirestoreSpec.run
      ]
  if all id results
    then exitSuccess
    else exitFailure
