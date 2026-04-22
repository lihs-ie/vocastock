{-# LANGUAGE OverloadedStrings #-}

module BillingWorker.StripePortSpec (run) where

import BillingWorker.BillingJob
  ( Plan (..),
    planCodeText,
    planForCode,
  )
import TestSupport (assertEqual, runNamed)
import Vocas.Worker.Core.MessageEnvelope (PlanCode (..))

run :: IO ()
run = runNamed "BillingWorker.StripePort (pure adapters)" $ do
  assertEqual "plan for FREE" PlanFree (planForCode FreePlan)
  assertEqual
    "plan for STANDARD_MONTHLY"
    PlanStandardMonthly
    (planForCode StandardMonthlyPlan)
  assertEqual
    "plan for PRO_MONTHLY"
    PlanProMonthly
    (planForCode ProMonthlyPlan)
  assertEqual "plan text FREE" "FREE" (planCodeText PlanFree)
  assertEqual
    "plan text STANDARD_MONTHLY"
    "STANDARD_MONTHLY"
    (planCodeText PlanStandardMonthly)
  assertEqual
    "plan text PRO_MONTHLY"
    "PRO_MONTHLY"
    (planCodeText PlanProMonthly)
