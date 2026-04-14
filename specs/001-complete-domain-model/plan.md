# Implementation Plan: ドメインモデル設計書の完成

**Branch**: `001-complete-domain-model` | **Date**: 2026-04-14 | **Spec**: [/Users/lihs/workspace/vocastock/specs/001-complete-domain-model/spec.md](/Users/lihs/workspace/vocastock/specs/001-complete-domain-model/spec.md)
**Input**: Feature specification from `/specs/001-complete-domain-model/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

英単語登録、解説生成、画像生成、学習状態管理に関わるドメイン文書を完成させる。
既存の `Explanation` と `VisualImage` を再整理し、登録状態、解説生成状態、
画像生成状態を分離した上で、識別子命名を `Identifier` 規約へ統一し、外部依存を
ポートとして定義し、要件文書と ADR との整合を取る。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Markdown 1.x, YAML, JSON  
**Primary Dependencies**: Spec Kit workflow, existing domain documents, requirements memo, ADR memo  
**Storage**: Git-managed repository files  
**Testing**: Manual cross-document review against spec, constitution, and plan artifacts  
**Target Platform**: Repository documentation for designers, reviewers, and implementers  
**Project Type**: documentation / domain-design  
**Performance Goals**: Reviewers can explain domain boundaries and async state rules within 5 minutes; terminology conflicts across docs are reduced to 0  
**Constraints**: No application code changes in this feature; incomplete generated results must remain hidden from users; external responsibilities must be described as ports; identifier naming must follow the constitution  
**Scale/Scope**: 4 domain documents, 2 external guidance documents, 1 spec bundle, 2 contract documents

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Domain impact is identified: `docs/internal/domain/common.md`,
      `docs/internal/domain/explanation.md`, `docs/internal/domain/service.md`,
      `docs/internal/domain/visual.md` are direct update targets, and
      `docs/external/requirements.md` plus `docs/external/adr.md` are sync targets.
- [x] Async generation flows define separate explanation/image lifecycle states,
      retry-safe transitions, and a completed-result-only visibility rule.
- [x] External AI, storage, pronunciation media, and word validation are planned as
      ports with dedicated contract documents.
- [x] User stories remain independently deliverable as core model completion,
      async/state clarification, and cross-document alignment.
- [x] Frequency, sophistication, proficiency, registration state, explanation state, and
      image state remain separated in the target model.
- [x] Identifier naming follows the constitution: no `id`/`xxxId`, identifier types use
      `XxxIdentifier`, self identifiers use `identifier`, and related references use
      concept names such as `entry`, `explanation`, and `image`.

Post-design re-check: PASS. Verified against `research.md`, `data-model.md`,
`contracts/domain-port-catalog.md`, and `contracts/user-visibility-contract.md`.

## Project Structure

### Documentation (this feature)

```text
specs/001-complete-domain-model/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
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

specs/001-complete-domain-model/
├── checklists/
│   └── requirements.md
├── contracts/
├── data-model.md
├── plan.md
├── quickstart.md
└── research.md
```

**Structure Decision**: 今回はドキュメント中心の feature として扱い、実装コードではなく
`docs/internal/domain/` と `docs/external/` を更新対象にする。設計成果物は
`specs/001-complete-domain-model/` 配下へ集約する。

## Complexity Tracking

> No constitution violations identified at planning time.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
