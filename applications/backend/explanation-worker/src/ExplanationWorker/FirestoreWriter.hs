{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firestore write adapter for completed explanations and
-- `VocabularyExpression.currentExplanation` handoff. Uses the shared
-- `vocas-worker-core` Firestore client so encoders / transport stay
-- consistent with the Rust side.
module ExplanationWorker.FirestoreWriter
  ( writeCompletedExplanation,
    switchCurrentExplanation,
  )
where

import Data.Text (Text)
import qualified Data.Text as T

import Vocas.Worker.Core.Firestore
  ( FirestoreClient,
    FirestoreError,
    createDocument,
    encodeFieldsObject,
    encodeIntegerField,
    encodeStringField,
    patchDocument,
  )

-- | Creates the `actors/{actor}/explanations/{explanationId}` document.
-- Returns the raw Firestore response for logging; callers only care
-- about the Either alignment.
writeCompletedExplanation ::
  FirestoreClient ->
  -- | actor UID
  Text ->
  -- | explanation document id
  Text ->
  -- | vocabulary expression id
  Text ->
  -- | Japanese-facing summary
  Text ->
  -- | sense count (>=1 enforced by caller)
  Integer ->
  IO (Either FirestoreError ())
writeCompletedExplanation client actor explanationId vocabularyExpressionId summary senseCount = do
  let collectionPath = T.concat ["actors/", actor, "/explanations"]
  let fieldsObject =
        encodeFieldsObject
          [ ("id", encodeStringField explanationId),
            ("vocabularyExpression", encodeStringField vocabularyExpressionId),
            ("text", encodeStringField summary),
            ("senseCount", encodeIntegerField senseCount)
          ]
  result <- createDocument client collectionPath explanationId fieldsObject
  pure (fmap (const ()) result)

-- | Patches the vocabulary-expression document so `currentExplanation`
-- points at the freshly-written explanation and `explanationStatus`
-- flips to `succeeded`. Also writes `id` + `text` because Firestore
-- PATCH on a missing document creates it with only the masked fields,
-- and the catalog read model (query-api) treats those two as required.
-- Re-writing them on update is harmless: vocabulary id derives from
-- normalized text, so both stay invariant for a given identifier.
switchCurrentExplanation ::
  FirestoreClient ->
  -- | actor UID
  Text ->
  -- | vocabulary expression identifier (e.g. "vocabulary:slug")
  Text ->
  -- | normalized text the identifier was derived from
  Text ->
  -- | explanation document id
  Text ->
  IO (Either FirestoreError ())
switchCurrentExplanation client actor vocabularyExpressionId normalizedText explanationId = do
  let documentPath =
        T.concat ["actors/", actor, "/vocabularyExpressions/", vocabularyExpressionId]
  let fieldsObject =
        encodeFieldsObject
          [ ("id", encodeStringField vocabularyExpressionId),
            ("text", encodeStringField normalizedText),
            ("currentExplanation", encodeStringField explanationId),
            ("explanationStatus", encodeStringField "succeeded")
          ]
  result <-
    patchDocument
      client
      documentPath
      ["id", "text", "currentExplanation", "explanationStatus"]
      fieldsObject
  pure (fmap (const ()) result)
