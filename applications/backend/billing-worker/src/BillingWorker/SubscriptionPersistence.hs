{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firestore write adapter for the single
-- `actors/{uid}/subscription/current` document. Each billing job
-- resets the document atomically to the incoming plan's allowance.
module BillingWorker.SubscriptionPersistence
  ( writeSubscriptionState,
  )
where

import Data.Text (Text)
import qualified Data.Text as T
import Data.Time.Clock.POSIX (getPOSIXTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import Data.Time.Clock (UTCTime)
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)

import BillingWorker.AllowanceReset
  ( Allowance (..),
    defaultAllowanceForPlan,
    entitlementForPlan,
    stateForPlan,
  )
import BillingWorker.WorkItemContract (Plan, planCodeText)
import Vocas.Worker.Core.Firestore
  ( FirestoreClient,
    FirestoreError,
    createDocument,
    encodeFieldsObject,
    encodeIntegerField,
    encodeMapField,
    encodeStringField,
    patchDocument,
  )

writeSubscriptionState ::
  FirestoreClient ->
  Text ->
  Plan ->
  IO (Either FirestoreError ())
writeSubscriptionState client actor plan = do
  now <- getPOSIXTime
  let renewedAt = formatRfc3339 (posixSecondsToUTCTime now)
  -- Next renewal: +30 days approximation (real billing queries Stripe);
  -- this matches the Rust pending-sync contract's best-effort cadence.
  let nextRenewalAt = formatRfc3339 (posixSecondsToUTCTime (now + (30 * 24 * 3600)))
  let allowance = defaultAllowanceForPlan plan
  let fieldsObject =
        encodeFieldsObject
          [ ("state", encodeStringField (stateForPlan plan)),
            ("plan", encodeStringField (planCodeText plan)),
            ("entitlement", encodeStringField (entitlementForPlan plan)),
            ( "allowance",
              encodeMapField
                [ ( "remainingExplanationGenerations",
                    encodeIntegerField (fromIntegral (allowanceExplanations allowance))
                  ),
                  ( "remainingImageGenerations",
                    encodeIntegerField (fromIntegral (allowanceImages allowance))
                  )
                ]
            ),
            ("renewedAt", encodeStringField renewedAt),
            ("nextRenewalAt", encodeStringField nextRenewalAt)
          ]
  let collectionPath = T.concat ["actors/", actor, "/subscription"]
  let documentPath = collectionPath <> "/current"
  -- Attempt create; fall back to patch when the document already exists.
  createResult <- createDocument client collectionPath "current" fieldsObject
  case createResult of
    Right _ -> pure (Right ())
    Left _ -> do
      patchResult <-
        patchDocument
          client
          documentPath
          ["state", "plan", "entitlement", "allowance", "renewedAt", "nextRenewalAt"]
          fieldsObject
      pure (fmap (const ()) patchResult)

formatRfc3339 :: UTCTime -> Text
formatRfc3339 t =
  T.pack (formatTime defaultTimeLocale "%Y-%m-%dT%H:%M:%S%QZ" t)
