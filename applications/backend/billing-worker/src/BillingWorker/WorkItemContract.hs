{-# LANGUAGE OverloadedStrings #-}

-- |
-- Billing job types. Mirrors the subset of
-- `Vocas.Worker.Core.MessageEnvelope` fields relevant for the billing
-- worker; worker-specific validation happens before Stripe is hit.
module BillingWorker.WorkItemContract
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
