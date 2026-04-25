-- |
-- Pure validator for the `previousImage` lineage invariants from
-- `docs/internal/domain/visual.md:54-56,65-66`:
--
--   * `previousImage` must reference an image in the **same** explanation.
--   * If both records carry a `sense`, those `sense` values must match.
--     A regenerated `sense=null` (explanation-wide) image may only point
--     at prior `sense=null` images. A `sense=Just ...` regeneration may
--     point at a prior record without a sense (the constraint engages
--     only when *both* sides have a sense per visual.md:55).
--   * Self-reference (the same identifier on both sides) is forbidden;
--     it would create a one-step cycle.
module ImageWorker.PreviousImageInvariant
  ( PreviousImageViolation (..),
    validatePreviousImageLink,
  )
where

import ImageWorker.ImagePersistence (CompletedVisualImageRecord (..))

data PreviousImageViolation
  = ExplanationMismatch
  | SenseMismatch
  | SelfReference
  deriving (Eq, Show)

-- | First argument is the *current* (just-generated) record; second is
-- the *prior* record being linked from `previousImage`. Returns
-- `Right ()` when the link satisfies the invariants, otherwise
-- `Left violation`.
validatePreviousImageLink ::
  CompletedVisualImageRecord ->
  CompletedVisualImageRecord ->
  Either PreviousImageViolation ()
validatePreviousImageLink current prior
  | recordIdentifier current == recordIdentifier prior = Left SelfReference
  | recordExplanation current /= recordExplanation prior = Left ExplanationMismatch
  | senseConflict (recordSense current) (recordSense prior) = Left SenseMismatch
  | otherwise = Right ()

-- | Sense comparison engages only when *both* sides have a sense per
-- visual.md:55. A null on either side is treated as compatible (the
-- explanation-wide / non-sense generation case).
senseConflict :: Maybe String -> Maybe String -> Bool
senseConflict (Just current) (Just prior) = current /= prior
senseConflict _ _ = False
