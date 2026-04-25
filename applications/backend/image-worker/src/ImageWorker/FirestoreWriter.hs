{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firestore write adapter for completed images, the
-- `Explanation.currentImage` handoff, and the lookup that resolves the
-- prior `currentImage` so a regenerated image can record its
-- predecessor as `previousImage` (issue #20 / `docs/internal/domain/visual.md:46`).
module ImageWorker.FirestoreWriter
  ( writeCompletedImage,
    switchCurrentImage,
    readCurrentImage,
  )
where

import qualified Data.Aeson as Aeson
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KeyMap
import Data.Text (Text)
import qualified Data.Text as T

import Vocas.Worker.Core.Firestore
  ( FirestoreClient,
    FirestoreError,
    createDocument,
    encodeFieldsObject,
    encodeNullableStringField,
    encodeStringField,
    getDocument,
    patchDocument,
    readStringField,
  )

writeCompletedImage ::
  FirestoreClient ->
  -- | actor UID
  Text ->
  -- | image document id
  Text ->
  -- | owning explanation id
  Text ->
  -- | asset reference (storage URL)
  Text ->
  -- | description
  Text ->
  -- | senseIdentifier (nullable)
  Maybe Text ->
  -- | senseLabel (nullable)
  Maybe Text ->
  -- | previousImage (nullable; null on first generation, set on regenerate)
  Maybe Text ->
  IO (Either FirestoreError ())
writeCompletedImage
  client
  actor
  imageId
  explanationId
  assetReference
  description
  senseIdentifier
  senseLabel
  previousImage = do
    let collectionPath = T.concat ["actors/", actor, "/images"]
    let fieldsObject =
          encodeFieldsObject
            [ ("id", encodeStringField imageId),
              ("explanation", encodeStringField explanationId),
              ("assetReference", encodeStringField assetReference),
              ("description", encodeStringField description),
              ("senseIdentifier", encodeNullableStringField senseIdentifier),
              ("senseLabel", encodeNullableStringField senseLabel),
              ("previousImage", encodeNullableStringField previousImage)
            ]
    result <- createDocument client collectionPath imageId fieldsObject
    pure (fmap (const ()) result)

switchCurrentImage ::
  FirestoreClient ->
  Text ->
  Text ->
  Text ->
  IO (Either FirestoreError ())
switchCurrentImage client actor explanationId imageId = do
  let documentPath =
        T.concat ["actors/", actor, "/explanations/", explanationId]
  let fieldsObject =
        encodeFieldsObject
          [("currentImage", encodeStringField imageId)]
  result <- patchDocument client documentPath ["currentImage"] fieldsObject
  pure (fmap (const ()) result)

-- | Resolves the existing `currentImage` for an explanation, used as the
-- new image's `previousImage` when a regeneration job is processed.
-- Returns `Nothing` when the explanation document is missing or has no
-- `currentImage` field yet (the first generation case).
readCurrentImage ::
  FirestoreClient ->
  -- | actor UID
  Text ->
  -- | explanation id
  Text ->
  IO (Maybe Text)
readCurrentImage client actor explanationId = do
  let path = T.concat ["actors/", actor, "/explanations/", explanationId]
  result <- getDocument client path
  case result of
    Left _ -> pure Nothing
    Right document -> pure (extractCurrentImage document)

extractCurrentImage :: Aeson.Value -> Maybe Text
extractCurrentImage (Aeson.Object docObj) =
  case KeyMap.lookup (Key.fromText "fields") docObj of
    Just fields -> readStringField fields "currentImage"
    Nothing -> Nothing
extractCurrentImage _ = Nothing
