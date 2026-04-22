{-# LANGUAGE OverloadedStrings #-}

module BillingWorker.AllowanceResetSpec (run) where

import BillingWorker.AllowanceReset
  ( Allowance (..),
    defaultAllowanceForPlan,
    entitlementForPlan,
    stateForPlan,
  )
import BillingWorker.BillingJob (Plan (..))
import TestSupport (assertEqual, runNamed)

run :: IO ()
run = runNamed "BillingWorker.AllowanceReset" $ do
  assertEqual
    "free allowance"
    (Allowance 10 3)
    (defaultAllowanceForPlan PlanFree)
  assertEqual
    "standard allowance"
    (Allowance 100 30)
    (defaultAllowanceForPlan PlanStandardMonthly)
  assertEqual
    "pro allowance"
    (Allowance 500 150)
    (defaultAllowanceForPlan PlanProMonthly)
  assertEqual
    "free entitlement"
    "FREE_BASIC"
    (entitlementForPlan PlanFree)
  assertEqual
    "standard entitlement"
    "PREMIUM_GENERATION"
    (entitlementForPlan PlanStandardMonthly)
  assertEqual
    "pro state active"
    "active"
    (stateForPlan PlanProMonthly)
