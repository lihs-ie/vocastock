module ImageWorker.PreviousImageInvariantSpec (run) where

import ImageWorker.ImagePersistence
  ( CompletedImageVisibility (..),
    CompletedVisualImageRecord (..),
  )
import ImageWorker.PreviousImageInvariant
  ( PreviousImageViolation (..),
    validatePreviousImageLink,
  )
import TestSupport

run :: IO ()
run = do
  runNamed "accepts same explanation and same sense" testSameExplanationSameSense
  runNamed "accepts same explanation and both senses null" testSameExplanationBothNullSense
  runNamed "accepts current sense with null prior sense" testCurrentHasSensePriorNull
  runNamed "rejects different explanation" testRejectsDifferentExplanation
  runNamed "rejects mismatched senses" testRejectsSenseMismatch
  runNamed "rejects self-reference" testRejectsSelfReference

mkRecord :: String -> String -> Maybe String -> Maybe String -> CompletedVisualImageRecord
mkRecord identifier explanation sense previousImage =
  CompletedVisualImageRecord
    { recordIdentifier = identifier,
      recordExplanation = explanation,
      recordSense = sense,
      recordAssetReference = "gs://vocastock/images/" ++ identifier ++ ".png",
      recordVisibility = HiddenUntilHandoff,
      recordAcceptedOrder = 1,
      recordPreviousImage = previousImage
    }

testSameExplanationSameSense :: IO ()
testSameExplanationSameSense = do
  let prior = mkRecord "img-old" "explanation-001" (Just "sense-001") Nothing
      current = mkRecord "img-new" "explanation-001" (Just "sense-001") (Just "img-old")
  assertEqual
    "same explanation, same sense → Right"
    (Right ())
    (validatePreviousImageLink current prior)

testSameExplanationBothNullSense :: IO ()
testSameExplanationBothNullSense = do
  let prior = mkRecord "img-old" "explanation-001" Nothing Nothing
      current = mkRecord "img-new" "explanation-001" Nothing (Just "img-old")
  assertEqual
    "same explanation, both senses null → Right"
    (Right ())
    (validatePreviousImageLink current prior)

testCurrentHasSensePriorNull :: IO ()
testCurrentHasSensePriorNull = do
  let prior = mkRecord "img-old" "explanation-001" Nothing Nothing
      current = mkRecord "img-new" "explanation-001" (Just "sense-001") (Just "img-old")
  assertEqual
    "current sense Just, prior sense null → Right (constraint engages only when both have a sense)"
    (Right ())
    (validatePreviousImageLink current prior)

testRejectsDifferentExplanation :: IO ()
testRejectsDifferentExplanation = do
  let prior = mkRecord "img-old" "explanation-001" (Just "sense-001") Nothing
      current = mkRecord "img-new" "explanation-002" (Just "sense-001") (Just "img-old")
  assertEqual
    "different explanation → Left ExplanationMismatch"
    (Left ExplanationMismatch)
    (validatePreviousImageLink current prior)

testRejectsSenseMismatch :: IO ()
testRejectsSenseMismatch = do
  let prior = mkRecord "img-old" "explanation-001" (Just "sense-002") Nothing
      current = mkRecord "img-new" "explanation-001" (Just "sense-001") (Just "img-old")
  assertEqual
    "different senses → Left SenseMismatch"
    (Left SenseMismatch)
    (validatePreviousImageLink current prior)

testRejectsSelfReference :: IO ()
testRejectsSelfReference = do
  let record = mkRecord "img-self" "explanation-001" (Just "sense-001") (Just "img-self")
  assertEqual
    "self-reference → Left SelfReference"
    (Left SelfReference)
    (validatePreviousImageLink record record)
