# Implementation Plan: 会員登録・ログイン・ログアウト設計

**Branch**: `008-auth-session-design` | **Date**: 2026-04-17 | **Spec**: [/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md](/Users/lihs/workspace/vocastock/specs/008-auth-session-design/spec.md)
**Input**: Feature specification from `/specs/008-auth-session-design/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

vocastock における会員登録、ログイン、ログアウトを、語彙学習のコアドメイン外にある
認証境界として設計する。認証 UI と provider 開始は Flutter client が担い、本人確認基盤は
Firebase Authentication を標準とする。利用可能状態の最終確定は backend 側で行い、
Flutter が取得した Firebase ID token を backend が検証し、検証済み Firebase subject
から actor / learner を解決した後に、アプリ本体へは正規化済み actor reference のみを
handoff する。`Basic` と `Google` を初期対象とし、`Apple ID` と `LINE` は追加コストが
発生しない場合のみ有効化候補とする。部分的に成立した認証状態を利用可能状態として
見せず、登録、ログイン、ログアウトの完了条件を Flutter / Firebase / backend handoff を
含めて contract として固定する。

## Technical Context

**Language/Version**: Markdown 1.x, YAML/JSON reference documents  
**Primary Dependencies**: 憲章、`docs/external/requirements.md`、`docs/external/adr.md`、`docs/internal/domain/common.md`、`docs/internal/domain/service.md`、`specs/003-architecture-design/`、`specs/004-tech-stack-definition/`、Flutter client auth UI、Firebase Authentication、Firebase ID token verification on backend  
**Storage**: Git-managed repository files、設計上で参照する抽象的な auth account store、external identity link store、session store、actor / learner resolution store、Firebase Authentication user records  
**Testing**: spec / constitution / architecture / auth-flow の手動クロスレビュー、Firebase ID token handoff review、provider policy review、session handoff review、partial-success rejection review  
**Target Platform**: Flutter client entry flow、Firebase Authentication identity boundary、custom backend token verification boundary、GraphQL / application entry boundary、session-backed protected operation flow  
**Project Type**: documentation / auth integration design  
**Performance Goals**: レビュー参加者が 10 分以内に `Basic` / `Google` の会員登録、ログイン、ログアウト導線を説明できること、5 分以内に Flutter / Firebase / backend の責務分離を説明できること、3 分以内に provider ごとの初期対象 / 条件付き対象を判定できること  
**Constraints**: product code は追加しない、認証は vocastock のコアドメイン外として扱う、Flutter は認証 UI と provider 開始のみを担う、Firebase Authentication を本人確認基盤とする、backend は Firebase ID token を検証してから actor / learner を解決する、アプリ本体へ Firebase token や `FirebaseUser` を渡さない、部分的に成立した認証状態を成功として返さない、`Basic` と `Google` を初期対象とする、`Apple ID` と `LINE` は追加コストなしの場合のみ候補とする、ログアウト後は保護操作に再認証を要求する、識別子命名は憲章に従う  
**Scale/Scope**: 3 つの主要 user flow、5 から 6 の boundary entity、4 つの契約文書、Firebase Auth handoff、provider 採用方針、session handoff ルールを含む auth design package を対象とする

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified. 認証は vocastock のコアドメイン外として扱い、`docs/internal/domain/*.md` は参照専用とする。domain aggregate や学習概念の更新は本 feature では行わない。
- [x] Async generation flows are unaffected. 本 feature は生成 workflow を追加せず、会員登録、ログイン、ログアウトを利用者から見て同期完了または失敗として扱う。部分成功を利用可能状態として見せない。
- [x] External dependencies remain behind ports/adapters. Flutter の provider 開始、Firebase Authentication、backend の ID token 検証、actor resolution はすべて auth boundary 越しに扱い、アプリ本体へ provider 固有詳細を持ち込まない。
- [x] User stories are independently reviewable. 基本導線、責務分離、provider 採用条件は別々にレビュー可能で、他ストーリー依存を持たない。
- [x] 学習概念を混同しない。auth account、external identity、verified Firebase identity、session、actor resolution は frequency、sophistication、proficiency、登録状態、生成状態と分離して扱う。
- [x] Identifier naming follows the constitution. `AuthAccountIdentifier`、`SessionIdentifier`、`ActorReferenceIdentifier` などの表記を前提にし、`id` / `xxxId` を採用しない。Firebase Authentication の `uid` は文書上 `Firebase subject` として扱い、アプリ内の識別子命名規則を崩さない。

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/auth-boundary-contract.md`, `contracts/auth-flow-contract.md`,
`contracts/session-handoff-contract.md`, and
`contracts/provider-availability-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/008-auth-session-design/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── auth-boundary-contract.md
│   ├── auth-flow-contract.md
│   ├── provider-availability-contract.md
│   └── session-handoff-contract.md
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
        ├── common.md
        ├── explanation.md
        ├── service.md
        └── visual.md

specs/
├── 003-architecture-design/
├── 004-tech-stack-definition/
└── 008-auth-session-design/
```

**Structure Decision**: 実装時の正本は `docs/external/requirements.md`、
`docs/external/adr.md`、認証連携を扱う本 feature の設計成果物に置く。`docs/internal/domain/*.md`
は参照専用とし、auth account や external identity をコアドメイン aggregate として
追加しない。008 では Flutter client が認証 UI と provider 開始を担い、Firebase
Authentication が本人確認基盤となり、backend が Firebase ID token を検証して
verified subject を actor / learner へ解決し、アプリ本体へは actor reference のみを
handoff する境界 contract を固定する。

## Complexity Tracking

> No constitution violations requiring justification were identified.
