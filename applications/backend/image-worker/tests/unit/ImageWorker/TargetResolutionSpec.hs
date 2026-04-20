module ImageWorker.TargetResolutionSpec (run) where

import ImageWorker.TargetResolution
import ImageWorker.WorkItemContract
import TestSupport

run :: IO ()
run = do
  runNamed "resolves a target with current adoption priority" testResolvesOwnPriority
  runNamed "resolves a target as superseded by newer accepted work" testResolvesSupersededPriority
  runNamed "rejects invalid target and ownership mismatches" testRejectsTargetFailures
  runNamed "renders resolution failures and priorities" testRendersLabels
  runNamed "covers accessors and show instances" testAccessorsAndShow

validatedWorkItem :: ValidatedWorkItem
validatedWorkItem =
  case validateWorkItem defaultWorkItem of
    Left intakeFailure -> error ("unexpected failure: " ++ renderIntakeFailure intakeFailure)
    Right value -> value

testResolvesOwnPriority :: IO ()
testResolvesOwnPriority =
  case resolveTarget validatedWorkItem defaultTargetContext of
    Left resolutionFailure -> error ("unexpected resolution failure: " ++ renderResolutionFailure resolutionFailure)
    Right resolvedTarget -> do
      assertEqual "resolved explanation" "explanation-001" (resolvedExplanation resolvedTarget)
      assertEqual "resolved learner" "learner-001" (resolvedLearner resolvedTarget)
      assertEqual "resolved sense" (Just "sense-001") (resolvedSense resolvedTarget)
      assertEqual "accepted order" 3 (resolvedAcceptedOrder resolvedTarget)
      assertEqual "current priority" OwnsCurrentAdoption (resolvedCurrentPriority resolvedTarget)

testResolvesSupersededPriority :: IO ()
testResolvesSupersededPriority =
  case resolveTarget defaultValidated defaultTargetContext {targetLatestAcceptedOrder = 4} of
    Left resolutionFailure -> error ("unexpected resolution failure: " ++ renderResolutionFailure resolutionFailure)
    Right resolvedTarget ->
      assertEqual
        "superseded priority"
        SupersededByNewerAccepted
        (resolvedCurrentPriority resolvedTarget)
  where
    defaultValidated = validatedWorkItem

testRejectsTargetFailures :: IO ()
testRejectsTargetFailures = do
  assertEqual
    "invalid target"
    (Left InvalidTarget)
    (resolveTarget validatedWorkItem defaultTargetContext {targetExists = False})
  assertEqual
    "ownership mismatch"
    (Left OwnershipMismatch)
    (resolveTarget validatedWorkItem defaultTargetContext {targetOwnedByLearner = False})
  assertEqual
    "explanation incomplete"
    (Left ExplanationNotCompleted)
    (resolveTarget validatedWorkItem defaultTargetContext {targetExplanationCompleted = False})
  assertEqual
    "sense mismatch"
    (Left SenseMismatch)
    (resolveTarget validatedWorkItem defaultTargetContext {targetSenseMatches = False})

testRendersLabels :: IO ()
testRendersLabels = do
  assertEqual "invalid target label" "invalid-target" (renderResolutionFailure InvalidTarget)
  assertEqual "ownership label" "ownership-mismatch" (renderResolutionFailure OwnershipMismatch)
  assertEqual "explanation label" "explanation-not-completed" (renderResolutionFailure ExplanationNotCompleted)
  assertEqual "sense label" "sense-mismatch" (renderResolutionFailure SenseMismatch)
  assertEqual "own priority label" "owns-current-adoption" (renderCurrentPriority OwnsCurrentAdoption)
  assertEqual
    "superseded priority label"
    "superseded-by-newer-accepted"
    (renderCurrentPriority SupersededByNewerAccepted)

testAccessorsAndShow :: IO ()
testAccessorsAndShow = do
  assertEqual "default target exists" True (targetExists defaultTargetContext)
  assertEqual "default ownership" True (targetOwnedByLearner defaultTargetContext)
  assertEqual "default explanation completed" True (targetExplanationCompleted defaultTargetContext)
  assertEqual "default sense matches" True (targetSenseMatches defaultTargetContext)
  assertEqual "default latest order" 3 (targetLatestAcceptedOrder defaultTargetContext)
  assertEqual "priority equality" True (OwnsCurrentAdoption == OwnsCurrentAdoption)
  assertEqual "resolution failure equality" True (InvalidTarget == InvalidTarget)
  assertEqual "show target context" True ("TargetContext" `elem` words (show defaultTargetContext))
  assertEqual "show resolution failure" "SenseMismatch" (show SenseMismatch)
