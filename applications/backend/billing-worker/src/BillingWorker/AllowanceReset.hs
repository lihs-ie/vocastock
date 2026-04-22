{-# LANGUAGE OverloadedStrings #-}

-- |
-- Plan-based allowance defaults applied whenever a subscription
-- transitions to `active`. Kept pure so unit tests can exercise the
-- policy without network IO.
module BillingWorker.AllowanceReset
  ( Allowance (..),
    defaultAllowanceForPlan,
    entitlementForPlan,
    stateForPlan,
  )
where

import Data.Text (Text)
import BillingWorker.BillingJob (Plan (..))

data Allowance = Allowance
  { allowanceExplanations :: Int,
    allowanceImages :: Int
  }
  deriving (Eq, Show)

defaultAllowanceForPlan :: Plan -> Allowance
defaultAllowanceForPlan PlanFree = Allowance {allowanceExplanations = 10, allowanceImages = 3}
defaultAllowanceForPlan PlanStandardMonthly =
  Allowance {allowanceExplanations = 100, allowanceImages = 30}
defaultAllowanceForPlan PlanProMonthly =
  Allowance {allowanceExplanations = 500, allowanceImages = 150}

entitlementForPlan :: Plan -> Text
entitlementForPlan PlanFree = "FREE_BASIC"
entitlementForPlan _ = "PREMIUM_GENERATION"

stateForPlan :: Plan -> Text
stateForPlan PlanFree = "active"
stateForPlan _ = "active"
