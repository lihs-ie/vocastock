{-# LANGUAGE OverloadedStrings #-}

-- |
-- Billing job types consumed by the PubSub pull loop. Mirrors the
-- subset of `Vocas.Worker.Core.MessageEnvelope` fields relevant for
-- the billing worker; worker-specific validation happens before Stripe
-- is hit. Kept separate from `BillingWorker.WorkItemContract` because
-- the latter models the spec 023 workflow state machine for pure
-- feature tests.
module BillingWorker.BillingJob
  ( BillingKind (..),
    Plan (..),
    BillingJob (..),
    planForCode,
    planCodeText,
  )
where

import Data.Text (Text)
import Vocas.Worker.Core.MessageEnvelope (PlanCode (..))

data BillingKind
  = PurchaseJob
  | RestorePurchaseJob
  deriving (Eq, Show)

data Plan
  = PlanFree
  | PlanStandardMonthly
  | PlanProMonthly
  deriving (Eq, Show)

data BillingJob = BillingJob
  { billingActor :: Text,
    billingIdempotencyKey :: Text,
    billingKind :: BillingKind,
    billingPlan :: Maybe Plan
  }
  deriving (Eq, Show)

planForCode :: PlanCode -> Plan
planForCode FreePlan = PlanFree
planForCode StandardMonthlyPlan = PlanStandardMonthly
planForCode ProMonthlyPlan = PlanProMonthly

planCodeText :: Plan -> Text
planCodeText PlanFree = "FREE"
planCodeText PlanStandardMonthly = "STANDARD_MONTHLY"
planCodeText PlanProMonthly = "PRO_MONTHLY"
