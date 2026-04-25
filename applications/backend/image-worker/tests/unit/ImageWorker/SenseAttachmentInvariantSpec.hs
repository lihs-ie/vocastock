module ImageWorker.SenseAttachmentInvariantSpec (run) where

import ImageWorker.SenseAttachmentInvariant
  ( SenseAttachmentViolation (..),
    validateSenseInExplanation,
  )
import TestSupport

run :: IO ()
run = do
  runNamed "accepts Nothing sense for empty senses" testNothingEmpty
  runNamed "accepts Nothing sense for non-empty senses" testNothingNonEmpty
  runNamed "accepts when sense belongs to explanation" testSenseInExplanation
  runNamed "rejects when sense not in explanation" testSenseNotInExplanation
  runNamed "rejects sense against empty explanation senses" testSenseAgainstEmpty

testNothingEmpty :: IO ()
testNothingEmpty =
  assertEqual
    "Nothing + empty senses → Right"
    (Right ())
    (validateSenseInExplanation [] Nothing)

testNothingNonEmpty :: IO ()
testNothingNonEmpty =
  assertEqual
    "Nothing + non-empty senses → Right"
    (Right ())
    (validateSenseInExplanation ["sense-001", "sense-002"] Nothing)

testSenseInExplanation :: IO ()
testSenseInExplanation =
  assertEqual
    "sense in senses → Right"
    (Right ())
    (validateSenseInExplanation ["sense-001", "sense-002"] (Just "sense-001"))

testSenseNotInExplanation :: IO ()
testSenseNotInExplanation =
  assertEqual
    "sense not in senses → Left SenseNotInExplanation"
    (Left SenseNotInExplanation)
    (validateSenseInExplanation ["sense-001"] (Just "sense-from-other-explanation"))

testSenseAgainstEmpty :: IO ()
testSenseAgainstEmpty =
  assertEqual
    "sense against empty senses → Left SenseNotInExplanation"
    (Left SenseNotInExplanation)
    (validateSenseInExplanation [] (Just "sense-001"))
