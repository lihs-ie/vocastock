# Implementation Plan: Command/Query Deployment Topology

**Branch**: `015-command-query-topology` | **Date**: 2026-04-19 | **Spec**: [/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md](/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md)
**Input**: Feature specification from `/Users/lihs/workspace/vocastock/specs/015-command-query-topology/spec.md`

## Summary

MVP から `Command Intake` と `Query Read` を別 Cloud Run deployment unit に分離し、client には `graphql-gateway` 経由の unified GraphQL endpoint を維持する。`command-api` は acceptance / idempotency / authoritative write / workflow dispatch を担い、`query-api` は completed result / status-only / subscription read を担う。両 service は backend で token 検証と actor handoff を行い、explanation / image / subscription reconciliation は独立 worker へ配置する。最終同期先は `docs/external/adr.md` と `docs/external/requirements.md` とする。

## Technical Context

**Language/Version**: Markdown 1.x, YAML, JSON documentation artifacts  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`specs/004-tech-stack-definition/`、`specs/008-auth-session-design/`、`specs/009-component-boundaries/`、`specs/010-subscription-component-boundaries/`、`specs/011-api-command-io-design/`、`specs/012-persistence-workflow-design/`、`specs/013-flutter-ui-state-design/`、`specs/014-billing-entitlement-policy/`  
**Storage**: 抽象的な Cloud Run deployment topology、Firestore authoritative write / read projection、Pub/Sub durable handoff、Firebase Authentication、Google Drive asset storage  
**Testing**: docs-first independent review、cross-artifact consistency review、Spec Kit analyze workflow  
**Target Platform**: Flutter mobile client、`graphql-gateway` on Cloud Run、Rust `command-api` on Cloud Run、Rust `query-api` on Cloud Run、Haskell workflow workers on Cloud Run、backend subscription reconciliation worker on Cloud Run、Firebase Authentication、Cloud Firestore、Pub/Sub、Google Drive  
**Project Type**: documentation / deployment topology design  
**Performance Goals**: third-party reviewer can explain topology allocation within 10 minutes; no topology ambiguity between command / query / worker / managed service; no required strong read-after-write in MVP  
**Constraints**: unified GraphQL endpoint must remain client-visible; `Command Intake` and `Query Read` must be separate deployment units from MVP; `graphql-gateway` must be an independent deployment unit; `command-api` and `query-api` must each perform backend token verification and actor handoff; `command-api` returns accepted / status handle while `query-api` returns status-only until projection catch-up; `Entitlement Policy` / `Subscription Feature Gate` / `Usage Metering / Quota Gate` must not become separate deployment units  
**Scale/Scope**: 7 major deployment units, 4 major request / workflow flows, 5 topology contracts, 1 source-of-truth update map

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified, and every changed aggregate, value object, domain event, or repository contract is mapped to updates in `docs/internal/domain/*.md` or explicitly marked as no domain change.
- [x] Async generation flows define lifecycle states, idempotent retry behavior, and user-visible status rules; incomplete generated results are never exposed to users.
- [x] All external AI, storage, media, and validation dependencies are introduced behind ports/adapters, with planned contract or integration coverage.
- [x] User stories remain independently implementable and testable; any cross-story dependency is justified in Complexity Tracking.
- [x] Frequency, sophistication, proficiency, registration state, explanation state, image state, purchase state, subscription state, entitlement, and usage allowance remain distinct concepts.
- [x] Identifier naming follows the constitution: no `id`/`xxxId`, identifier types use `XxxIdentifier`, self identifiers use `identifier`, and related identifier fields use concept names such as `bank`, `entry`, or `image`.

## Project Structure

### Documentation (this feature)

```text
specs/015-command-query-topology/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── async-worker-allocation-contract.md
│   ├── command-query-separation-contract.md
│   ├── deployment-topology-contract.md
│   ├── gateway-routing-contract.md
│   └── source-of-truth-update-contract.md
└── tasks.md
```

### Source Code (repository root)

```text
docs/
├── external/
│   ├── adr.md
│   └── requirements.md
└── internal/
    └── domain/

specs/
├── 004-tech-stack-definition/
├── 008-auth-session-design/
├── 009-component-boundaries/
├── 010-subscription-component-boundaries/
├── 011-api-command-io-design/
├── 012-persistence-workflow-design/
├── 013-flutter-ui-state-design/
├── 014-billing-entitlement-policy/
└── 015-command-query-topology/
```

**Structure Decision**: 015 は docs-first の deployment topology feature とし、実装コードはまだ追加しない。正本更新先は `docs/external/adr.md` と `docs/external/requirements.md`、再同期対象は 004 / 008 / 009 / 010 / 011 / 012 / 013 / 014 の関連 spec package とする。

## Complexity Tracking

該当なし
