{-# LANGUAGE OverloadedStrings #-}

module MessageEnvelopeSpec (run) where

import qualified Data.ByteString.Lazy.Char8 as LBS8
import Vocas.Worker.Core.MessageEnvelope
  ( DispatchEnvelope (..),
    DispatchKind (..),
    GenerationTarget (..),
    PlanCode (..),
    decodeDispatchEnvelope,
  )

run :: IO Bool
run = do
  putStrLn "# MessageEnvelopeSpec"
  cases <-
    sequence
      [ caseExplanation,
        caseRetry,
        casePurchase,
        caseRestore,
        caseImageWithSense,
        caseImageWithoutSense,
        caseMalformed
      ]
  pure (all id cases)

assertEq :: (Eq a, Show a) => String -> a -> a -> IO Bool
assertEq label expected actual =
  if expected == actual
    then do
      putStrLn ("  ok  " ++ label)
      pure True
    else do
      putStrLn
        ( "  FAIL "
            ++ label
            ++ "\n    expected="
            ++ show expected
            ++ "\n    actual="
            ++ show actual
        )
      pure False

caseExplanation :: IO Bool
caseExplanation = do
  let raw =
        LBS8.pack
          "{\"actor\":\"stub-actor-demo\",\"idempotencyKey\":\"k1\",\"kind\":\"explanation-generation\",\"vocabularyExpression\":\"vocabulary:run\",\"restartRequested\":false}"
  case decodeDispatchEnvelope raw of
    Right envelope -> do
      results <-
        sequence
          [ assertEq "actor" "stub-actor-demo" (envelopeActor envelope),
            assertEq "key" "k1" (envelopeIdempotencyKey envelope),
            assertEq "kind" ExplanationGenerationKind (envelopeKind envelope),
            assertEq "vocab" "vocabulary:run" (envelopeVocabularyExpression envelope),
            assertEq "restart" False (envelopeRestartRequested envelope),
            assertEq "retry target" Nothing (envelopeRetryTarget envelope),
            assertEq "plan code" Nothing (envelopePlanCode envelope)
          ]
      pure (all id results)
    Left err -> do
      putStrLn ("  FAIL explanation envelope: " ++ err)
      pure False

caseRetry :: IO Bool
caseRetry = do
  let raw =
        LBS8.pack
          "{\"actor\":\"a\",\"idempotencyKey\":\"k2\",\"kind\":\"retry\",\"vocabularyExpression\":\"vocabulary:run\",\"restartRequested\":true,\"retryTarget\":\"IMAGE\"}"
  case decodeDispatchEnvelope raw of
    Right envelope -> do
      results <-
        sequence
          [ assertEq "kind" RetryKind (envelopeKind envelope),
            assertEq "retry target" (Just ImageTarget) (envelopeRetryTarget envelope),
            assertEq "restart" True (envelopeRestartRequested envelope)
          ]
      pure (all id results)
    Left err -> do
      putStrLn ("  FAIL retry envelope: " ++ err)
      pure False

casePurchase :: IO Bool
casePurchase = do
  let raw =
        LBS8.pack
          "{\"actor\":\"a\",\"idempotencyKey\":\"k3\",\"kind\":\"purchase\",\"restartRequested\":false,\"planCode\":\"STANDARD_MONTHLY\"}"
  case decodeDispatchEnvelope raw of
    Right envelope -> do
      results <-
        sequence
          [ assertEq "kind" PurchaseKind (envelopeKind envelope),
            assertEq "plan code" (Just StandardMonthlyPlan) (envelopePlanCode envelope)
          ]
      pure (all id results)
    Left err -> do
      putStrLn ("  FAIL purchase envelope: " ++ err)
      pure False

caseRestore :: IO Bool
caseRestore = do
  let raw =
        LBS8.pack
          "{\"actor\":\"a\",\"idempotencyKey\":\"k4\",\"kind\":\"restore-purchase\",\"restartRequested\":false}"
  case decodeDispatchEnvelope raw of
    Right envelope -> assertEq "kind" RestorePurchaseKind (envelopeKind envelope)
    Left err -> do
      putStrLn ("  FAIL restore envelope: " ++ err)
      pure False

caseImageWithSense :: IO Bool
caseImageWithSense = do
  let raw =
        LBS8.pack
          "{\"actor\":\"a\",\"idempotencyKey\":\"k5\",\"kind\":\"image-generation\",\"vocabularyExpression\":\"vocabulary:run\",\"restartRequested\":false,\"senseIdentifier\":\"sense-001\"}"
  case decodeDispatchEnvelope raw of
    Right envelope -> do
      results <-
        sequence
          [ assertEq "kind" ImageGenerationKind (envelopeKind envelope),
            assertEq "sense identifier" (Just "sense-001") (envelopeSenseIdentifier envelope)
          ]
      pure (all id results)
    Left err -> do
      putStrLn ("  FAIL image-with-sense envelope: " ++ err)
      pure False

caseImageWithoutSense :: IO Bool
caseImageWithoutSense = do
  let raw =
        LBS8.pack
          "{\"actor\":\"a\",\"idempotencyKey\":\"k6\",\"kind\":\"image-generation\",\"vocabularyExpression\":\"vocabulary:run\",\"restartRequested\":false}"
  case decodeDispatchEnvelope raw of
    Right envelope ->
      assertEq "sense identifier defaults to Nothing" Nothing (envelopeSenseIdentifier envelope)
    Left err -> do
      putStrLn ("  FAIL image-without-sense envelope: " ++ err)
      pure False

caseMalformed :: IO Bool
caseMalformed = do
  let raw = LBS8.pack "{this is not json"
  case decodeDispatchEnvelope raw of
    Left _ -> do
      putStrLn "  ok  rejects non-json payload"
      pure True
    Right _ -> do
      putStrLn "  FAIL malformed payload should fail to decode"
      pure False
