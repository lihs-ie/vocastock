{-# LANGUAGE OverloadedStrings #-}

-- |
-- Firestore write adapter for completed images and
-- `Explanation.currentImage` handoff.
module ImageWorker.FirestoreWriter
  ( writeCompletedImage,
    switchCurrentImage,
  )
where

import Data.Text (Text)
import qualified Data.Text as T

import Vocas.Worker.Core.Firestore
  ( FirestoreClient,
    FirestoreError,
    createDocument,
    encodeFieldsObject,
    encodeNullableStringField,
    encodeStringField,
    patchDocument,
  )

writeCompletedImage ::
  FirestoreClient ->
  Text ->
  Text ->
  Text ->
  Text ->
  Text ->
  Maybe Text ->
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
  senseLabel = do
    let collectionPath = T.concat ["actors/", actor, "/images"]
    let fieldsObject =
          encodeFieldsObject
            [ ("id", encodeStringField imageId),
              ("explanation", encodeStringField explanationId),
              ("assetReference", encodeStringField assetReference),
              ("description", encodeStringField description),
              ("senseIdentifier", encodeNullableStringField senseIdentifier),
              ("senseLabel", encodeNullableStringField senseLabel)
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
