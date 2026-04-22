module Main (main) where

import qualified BillingWorker.AllowanceResetSpec
import qualified BillingWorker.StripeLiveSpec
import qualified BillingWorker.StripePortSpec
import System.Exit (exitFailure, exitSuccess)

main :: IO ()
main = do
  results <-
    sequence
      [ BillingWorker.AllowanceResetSpec.run,
        BillingWorker.StripePortSpec.run,
        BillingWorker.StripeLiveSpec.run
      ]
  if all id results
    then exitSuccess
    else exitFailure
