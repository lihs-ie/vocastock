# Contract: Deferred Scope

## Purpose

この feature が ownership を持つ component definition と、別 feature が正本を持つ責務を切り分ける。

## Ownership Matrix

| Concern | Owned By 009? | Authoritative Source | Notes |
|---------|---------------|----------------------|-------|
| top-level responsibility taxonomy | Yes | `specs/009-component-boundaries/` | 6 つの top-level 責務と内側基盤の表現を定義する |
| current-list to canonical allocation | Yes | `specs/009-component-boundaries/` | keep / split / add / defer を定義する |
| auth/session implementation detail | No | `specs/008-auth-session-design/` | 009 は `Actor/Auth Boundary` の配置だけを扱う |
| command acceptance semantics | No | `specs/007-backend-command-design/` | 009 は `Command Intake` の placement だけを扱う |
| retry / regenerate / dispatch rules | No | `specs/007-backend-command-design/` | async workflow の意味論は 007 側が正本 |
| query model schema / persistence | No | future query feature, `docs/external/adr.md` | 009 は `Query Read` component の存在だけを定義する |
| vendor-specific adapter implementation | No | future implementation | 009 は adapter boundary のみ定義する |
| multiple current image / meaning gallery | No | follow-on scope | 009 は単一 `Explanation.currentImage` 前提を維持する |

## Scope Rules

- 009 は component placement と dependency direction を定義してよいが、既存 feature の behavioral contract を上書きしてはならない
- deferred concern を current component catalog へ取り込む場合は、対応する正本 feature の更新を伴わなければならない
- `docs/external/adr.md` 更新時も、007 / 008 / domain docs の責務境界と矛盾してはならない

## Follow-On Items

- query model 実装 feature で `Query Read` 配下の storage / schema / projection detail を具体化する
- implementation feature で `External Adapters` 配下の vendor-specific SDK / API choice を具体化する
- follow-on image feature で multiple current image / gallery 化を検討する場合は、009 の single-current 前提を明示的に更新する
