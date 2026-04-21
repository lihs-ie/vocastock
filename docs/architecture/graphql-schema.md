# vocastock GraphQL schema — architecture notes

## Single source of truth

`applications/backend/graphql-gateway/schema/schema.graphql` is the
canonical declaration of every type, enum, input, and root operation
the mobile client consumes. It is referenced by:

- **graphql-gateway allowlist** (`applications/backend/graphql-gateway/src/gateway_routing/graphql/operation_allowlist.rs`)
  — picks allowed operation names + routes each to `command-api`
  (mutations) or `query-api` (queries). Operations not listed in the
  schema are rejected with `unsupported_operation`.
- **Flutter ferry client** (`applications/mobile/build.yaml` →
  `applications/mobile/lib/src/infrastructure/graphql/schema.graphql`,
  which is a copy of the gateway schema). `dart run build_runner build`
  produces typed request / response classes under
  `lib/src/infrastructure/graphql/**/__generated__`.

Keep the two `schema.graphql` files in sync — the build step re-copies
when the shared seed script runs. In the short term, regenerate the
mobile copy manually after editing the gateway schema:

```bash
cp applications/backend/graphql-gateway/schema/schema.graphql \
   applications/mobile/lib/src/infrastructure/graphql/schema.graphql
cd applications/mobile && dart run build_runner build --delete-conflicting-outputs
```

## Operation surface (current allowlist)

### Queries

| Operation | Downstream | Notes |
|---|---|---|
| `vocabularyCatalog` | `query-api /vocabulary-catalog` | returns `VocabularyCatalog`. Backed by `InMemoryCatalogProjectionSource` by default; `VOCAS_PRODUCTION_ADAPTERS=true` swaps to the Firestore-backed source reading `/actors/{uid}/vocabularyExpressions`. |
| `vocabularyExpressionDetail(identifier)` | `query-api /vocabulary-expression-detail` | nullable result; relayed via the gateway's generic query path. Endpoint implementation pending (Section B3 follow-up). |
| `explanationDetail(identifier)` | `query-api /explanation-detail` | nullable, for `ExplanationDetail` screen. Endpoint pending. |
| `imageDetail(identifier)` | `query-api /image-detail` | nullable, for `ImageDetail` screen. Endpoint pending. |
| `subscriptionStatus` | `query-api /subscription-status` | for `SubscriptionStatus` + `Paywall` screens. Endpoint pending. |
| `actorHandoffStatus` | `query-api /actor-handoff-status` | lightweight session probe used after sign-in. Endpoint pending. |
| `learningState(identifier)` | `query-api /learning-state` | spec 005 LearningState aggregate; backend pending — mobile falls back to `StubLearningStateReader`. |

### Mutations

| Operation | Downstream | Notes |
|---|---|---|
| `registerVocabularyExpression` | `command-api /commands/register-vocabulary-expression` | live today; uses `InMemoryCommandStore` + `InMemoryDispatchPort` until the Firestore / PubSub adapters land. |
| `requestExplanationGeneration` | `command-api /commands/request-explanation-generation` | endpoint pending. |
| `requestImageGeneration` | `command-api /commands/request-image-generation` | endpoint pending. |
| `retryGeneration` | `command-api /commands/retry-generation` | endpoint pending. |
| `requestPurchase` | `command-api /commands/request-purchase` | endpoint pending; billing-worker will consume the resulting PubSub event. |
| `requestRestorePurchase` | `command-api /commands/request-restore-purchase` | endpoint pending. |

Sign-in / sign-out intentionally stay outside the GraphQL surface —
the mobile client consumes Firebase Auth directly and the ID token is
attached to every GraphQL request via the HTTP link (see
`applications/mobile/lib/src/infrastructure/graphql/graphql_client.dart`).

## Adapter selection (Flutter side)

`applications/mobile/lib/src/app_bindings.dart` exposes a build-time
flag:

```dart
const bool useLiveBackend = bool.fromEnvironment('USE_LIVE_BACKEND');
```

Every reader / command provider evaluates the flag:

- `useLiveBackend == false` (default) → in-memory stubs under
  `lib/src/infrastructure/stub/*`. All 226 Flutter tests stay hermetic.
- `useLiveBackend == true` → ferry / Firebase adapters under
  `lib/src/infrastructure/graphql/adapters/*` and
  `lib/src/infrastructure/firebase/*`.

Enabling:

```bash
cd applications/mobile
flutter run -d <device-id> --dart-define=USE_LIVE_BACKEND=true
```

`main()` initialises Firebase (Auth + Storage emulator) only when the
flag is set, so test runs do not pay the Firebase startup cost.

## Adapter selection (Rust backend)

`VOCAS_PRODUCTION_ADAPTERS=true` opts the backend services into
live-data mode. Combined with `FIRESTORE_EMULATOR_HOST` the query-api
targets the local Firebase emulator. When the flag is unset (the
default), every downstream source stays on its in-memory fixture —
which is what the `public_graphql_gateway_relays_allowlisted_operations_against_dockerized_services`
feature test relies on.

## Remaining backend work

See `docs/architecture/graphql-schema.md` (this file) + the PR
description:

- **Section B2**: `command-api` needs a Firestore-backed command store
  and a PubSub dispatch port so registration / generation mutations
  persist and fan out.
- **Section B3 follow-up**: the five new query-api endpoints
  (vocabulary expression / completed detail × 2 / subscription / actor
  handoff) need Firestore readers + HTTP routes.
- **Section B4**: command-api needs generation / purchase / retry
  endpoints.
- **Section D**: Haskell workers have to subscribe to PubSub and call
  LLM / image / billing providers instead of the current
  `forever threadDelay`.

Each of those pieces is independently shippable once the shared
Firestore / PubSub / FirebaseAuth client crate (`packages/rust/shared-integrations`)
lands.
