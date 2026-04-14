# vocastock Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-14

## Active Technologies

- Markdown 1.x, YAML, JSON + Spec Kit workflow, existing domain documents, requirements memo, ADR memo (001-complete-domain-model)

## Project Structure

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
└── 001-complete-domain-model/
    ├── contracts/
    ├── data-model.md
    ├── plan.md
    ├── quickstart.md
    ├── research.md
    └── spec.md
```

## Commands

- Inspect current feature spec: `sed -n '1,220p' specs/001-complete-domain-model/spec.md`
- Inspect current implementation plan: `sed -n '1,260p' specs/001-complete-domain-model/plan.md`
- Search domain terminology across docs: `rg -n "VocabularyEntry|Explanation|VisualImage|Identifier|Proficiency|Generation" docs specs`

## Code Style

Markdown 1.x, YAML, JSON: Keep terminology consistent across `docs/internal/domain/`,
`docs/external/`, and `specs/`. When a domain boundary changes, update the affected
domain docs in the same change set. Identifier types must use `XxxIdentifier`,
an aggregate's own identifier field must be `identifier`, and related identifier
fields must use concept names such as `bank`, `entry`, or `image`.

## Recent Changes

- 001-complete-domain-model: Added Markdown 1.x, YAML, JSON + Spec Kit workflow, existing domain documents, requirements memo, ADR memo

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
