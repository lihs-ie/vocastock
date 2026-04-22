-- |
-- Re-exports the worker-facing surface of `vocas-worker-core`.
--
-- Haskell workers (`explanation-worker`, `image-worker`,
-- `billing-worker`) talk to the Firebase emulator suite over plain
-- REST; this module bundles the PubSub pull/ack, Firestore
-- GET/POST/PATCH, Storage PUT clients, the envelope decoder that
-- matches `command-api`'s `PubSubDispatchPort::build_dispatch_message`
-- output, and environment-resolution helpers.
module Vocas.Worker.Core
  ( module Vocas.Worker.Core.Env,
    module Vocas.Worker.Core.Http,
    module Vocas.Worker.Core.PubSub,
    module Vocas.Worker.Core.Firestore,
    module Vocas.Worker.Core.Storage,
    module Vocas.Worker.Core.MessageEnvelope,
  )
where

import Vocas.Worker.Core.Env
import Vocas.Worker.Core.Firestore
import Vocas.Worker.Core.Http
import Vocas.Worker.Core.MessageEnvelope
import Vocas.Worker.Core.PubSub
import Vocas.Worker.Core.Storage
