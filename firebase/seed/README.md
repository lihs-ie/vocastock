# Firebase emulator seed data

`firebase/seed/` contains the fixtures that populate the local Firebase
emulator suite with data matching the vocastock Flutter stub adapters
(`StubActorHandoffController`, `StubVocabularyCatalog`,
`StubCompletedDetails`, `StubSubscriptionState`).

Running the seed is idempotent: re-running upserts the users and
replaces the Firestore documents so the emulator always reaches the
same known-good state.

## What gets seeded

### Auth emulator (`http://127.0.0.1:${FIREBASE_AUTH_PORT}`)

| UID | Email | Password | Plan |
|---|---|---|---|
| `stub-actor-demo` | `demo@vocastock.test` | `demo1234` | `standardMonthly` (active) |
| `stub-actor-free` | `free@vocastock.test` | `free1234` | `free` (active) |

Both users are `emailVerified: true`; custom claims carry `plan` and
`role`.

### Firestore emulator (`http://127.0.0.1:${FIREBASE_FIRESTORE_PORT}`)

Document layout (one actor subtree per learner):

```
/actors/{actorId}                                 — profile + session metadata
/actors/{actorId}/subscription/current            — SubscriptionStatusView
/actors/{actorId}/vocabularyExpressions/{vocabId} — VocabularyExpressionEntry
/actors/{actorId}/explanations/{explanationId}    — CompletedExplanationDetail
/actors/{actorId}/images/{imageId}                — CompletedImageDetail
```

`stub-actor-demo` is populated with four vocabulary expressions covering
every status combination the Flutter UI can reach:

| text | explanationStatus | imageStatus |
|---|---|---|
| `run` | succeeded (4 senses) | succeeded |
| `serendipity` | succeeded (1 sense) | pending |
| `ubiquitous` | pending | pending |
| `halcyon` | failedFinal | pending |

`stub-actor-free` has no vocabulary yet — useful for exercising the
empty-catalog placeholder.

### Storage emulator (`http://127.0.0.1:${FIREBASE_STORAGE_PORT}`)

A single 1×1 transparent PNG placeholder is uploaded at
`actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png`
so downstream code that dereferences `CompletedImageDetail.assetReference`
has something to fetch.

## Wiring status

- **Firestore (catalog)**: `query-api` reads the seed through
  `FirestoreCatalogProjectionSource` when
  `VOCAS_PRODUCTION_ADAPTERS=true` (see
  `applications/backend/query-api/src/query_catalog_read/catalog/firestore_source.rs`).
  The Flutter `useLiveBackend` flag targets the same catalog via
  `graphql-gateway`.
- **Auth**: consumed directly by Flutter through `FirebaseAuth`; the
  gateway forwards the resulting ID token untouched.
- **Storage**: the seeded placeholder PNG is resolved by
  `FirebaseStorageImageResolver` when the `ImageDetail` screen runs in
  live mode.
- **Remaining gaps**: `vocabularyExpressionDetail`, `explanationDetail`,
  `imageDetail`, `subscriptionStatus`, `actorHandoffStatus`,
  `learningState` all relay through the gateway, but the downstream
  query-api endpoints are still pending. See
  `docs/architecture/graphql-schema.md`.

## How to run

Prerequisites — the Firebase emulator suite has to be up:

```bash
bash scripts/firebase/start_emulators.sh
bash scripts/firebase/smoke_local_stack.sh   # optional: wait until ready
```

Seed the running emulators:

```bash
bash scripts/firebase/seed_emulators.sh
```

Reset-then-seed (wipe previously seeded users / documents first):

```bash
bash scripts/firebase/seed_emulators.sh --reset
```

The wrapper reads port values from `docker/firebase/env/.env` (falling
back to `.env.example`) and installs `firebase-admin` into
`firebase/seed/node_modules` on its first run. Re-runs are offline.

## Persisting the seed across emulator restarts

The compose file wires the emulators with
`--import /workspace/.artifacts/firebase/import` and
`--export-on-exit /workspace/.artifacts/firebase/export` — i.e. whatever
is in `.artifacts/firebase/export/` at shutdown becomes the `import/`
baseline on the next `start_emulators.sh` call *if you move the export
into place*.

To snapshot the seeded state as the new baseline:

```bash
# 1. Seed
bash scripts/firebase/seed_emulators.sh

# 2. Stop the emulators so --export-on-exit fires
bash scripts/firebase/stop_emulators.sh

# 3. Promote the export to the import baseline
rm -rf .artifacts/firebase/import
mv .artifacts/firebase/export .artifacts/firebase/import
mkdir -p .artifacts/firebase/export

# 4. Restart; seed data is pre-loaded
bash scripts/firebase/start_emulators.sh
```

## Editing the fixtures

`fixtures.json` is the single source of truth; `seed.mjs` just walks it
and writes each entry via `firebase-admin`. When adding a field that a
Flutter domain model already exposes (see
`applications/mobile/lib/src/domain/...`) keep the JSON field name and
type identical to the Dart constructor so the future backend adapter
can decode the document without translation.

If you introduce a new collection, update both the JSON and the
`seedFirestore` function in `seed.mjs`.
