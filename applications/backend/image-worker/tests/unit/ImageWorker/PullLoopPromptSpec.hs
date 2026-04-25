module ImageWorker.PullLoopPromptSpec (run) where

import qualified Data.Text as T

import ImageWorker.PullLoop (imagePrompt)
import TestSupport
import Vocas.Worker.Core.MessageEnvelope
  ( DispatchEnvelope (..),
    DispatchKind (..),
  )

run :: IO ()
run = do
  runNamed "uses normalized text and folds in sense identifier" testWithSense
  runNamed "uses normalized text without sense suffix when sense absent" testWithoutSense
  runNamed "falls back to vocabulary expression when normalized text missing" testFallbackSubject

baseEnvelope :: DispatchEnvelope
baseEnvelope =
  DispatchEnvelope
    { envelopeActor = T.pack "stub-actor-demo",
      envelopeIdempotencyKey = T.pack "feat-image-1",
      envelopeKind = ImageGenerationKind,
      envelopeVocabularyExpression = T.pack "vocabulary:run",
      envelopeRestartRequested = False,
      envelopeNormalizedText = Just (T.pack "run"),
      envelopeRetryTarget = Nothing,
      envelopePlanCode = Nothing,
      envelopeSenseIdentifier = Nothing
    }

testWithSense :: IO ()
testWithSense = do
  let envelope = baseEnvelope {envelopeSenseIdentifier = Just (T.pack "sense-001")}
      prompt = T.unpack (imagePrompt envelope)
  assertEqual
    "prompt mentions vocabulary"
    True
    (T.pack "\"run\"" `T.isInfixOf` imagePrompt envelope)
  assertEqual
    "prompt folds in sense"
    True
    (T.pack "(sense: sense-001)" `T.isInfixOf` imagePrompt envelope)
  assertEqual
    "prompt is the documented shape"
    "Illustration visualising \"run\" (sense: sense-001)"
    prompt

testWithoutSense :: IO ()
testWithoutSense = do
  let prompt = T.unpack (imagePrompt baseEnvelope)
  assertEqual
    "prompt is the no-sense baseline"
    "Illustration visualising \"run\""
    prompt
  assertEqual
    "prompt does not contain sense suffix"
    False
    (T.pack "sense:" `T.isInfixOf` imagePrompt baseEnvelope)

testFallbackSubject :: IO ()
testFallbackSubject = do
  let envelope = baseEnvelope {envelopeNormalizedText = Nothing}
      prompt = T.unpack (imagePrompt envelope)
  assertEqual
    "prompt falls back to vocabulary expression when normalized text absent"
    "Illustration visualising \"vocabulary:run\""
    prompt
