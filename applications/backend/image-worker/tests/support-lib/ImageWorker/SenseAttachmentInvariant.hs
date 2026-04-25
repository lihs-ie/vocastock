-- |
-- Pure validator for the same-explanation `sense` invariant from
-- `docs/internal/domain/visual.md:45,52` and
-- `docs/internal/domain/explanation.md:16-28,188-190`:
--
--   * `VisualImage.sense` (`SenseIdentifier`, 0..1) must reference a
--     `Sense` owned by the **same** Explanation that this image is
--     attached to.
--   * `sense = null` (explanation-wide image) is always valid.
--
-- This module documents the invariant so issue #22's acceptance criterion
-- "同一 explanation 外の sense を指定したら domain invariant で reject"
-- has an executable spec. It is **not** wired into the production
-- `PullLoop` — runtime rejection would require a Firestore read of the
-- explanation's `senses` array (mirroring `readCurrentImage`), which is
-- intentionally out of scope for the "low" priority issue. The pure
-- validator captures the rule for future runtime adoption.
module ImageWorker.SenseAttachmentInvariant
  ( SenseAttachmentViolation (..),
    validateSenseInExplanation,
  )
where

data SenseAttachmentViolation
  = SenseNotInExplanation
  deriving (Eq, Show)

-- | First argument is the explanation's owned `Sense` identifiers; the
-- second is the candidate `senseIdentifier` requested by the dispatch
-- envelope. Returns `Right ()` when the link satisfies the invariant,
-- `Left SenseNotInExplanation` otherwise.
validateSenseInExplanation ::
  -- | senses owned by the explanation
  [String] ->
  -- | candidate sense identifier (Nothing = explanation-wide image)
  Maybe String ->
  Either SenseAttachmentViolation ()
validateSenseInExplanation _ Nothing = Right ()
validateSenseInExplanation senses (Just candidate)
  | candidate `elem` senses = Right ()
  | otherwise = Left SenseNotInExplanation
