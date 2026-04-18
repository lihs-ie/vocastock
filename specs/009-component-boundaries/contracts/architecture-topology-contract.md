# Contract: Architecture Topology

## Purpose

component boundary 定義における主軸アーキテクチャ、内側基盤、top-level 責務、依存方向を固定する。

## Inner Foundation Layers

| Layer | Owns | Must Not Own | Depends On |
|-------|------|--------------|------------|
| `Domain Core` | `Learner`、`VocabularyExpression`、`LearningState`、`Explanation`、`VisualImage`、`Sense` の用語と不変条件 | UI、auth/session detail、vendor API | none |
| `Application Coordination` | domain を使った use-case 協調、boundary ごとの依存規則 | top-level catalog の代替表現、vendor 固有 credential | `Domain Core`、port contracts |

## Top-Level Responsibilities

| Responsibility | Owns | Must Not Own | Depends On |
|----------------|------|--------------|------------|
| `Presentation` | user input、completed result 表示、status 表示 | workflow 実行、vendor API、auth account lifecycle | `Actor/Auth Boundary`、`Command Intake`、`Query Read` |
| `Actor/Auth Boundary` | `Learner` 解決、actor handoff | auth/session 実装全体、domain aggregate 更新 | `Application Coordination`、auth/session outputs |
| `Command Intake` | request acceptance、validation orchestration、duplicate lookup | completed result read、workflow 本体、UI rendering | `Application Coordination`、`External Adapters` |
| `Query Read` | completed result / history / status read | request acceptance、workflow orchestration | `Application Coordination`、`External Adapters` |
| `Async Generation` | long-running workflow execution | direct UI rendering、raw auth handling、request acceptance | `Application Coordination`、`External Adapters` |
| `External Adapters` | validation / generation / storage / media との接続 | domain 判断、UI interaction、component allocation の最終判断 | external services only |

## Dependency Rules

- `Presentation` は `Async Generation` を直接起動してはならず、`Command Intake` または `Query Read` を経由しなければならない
- `Actor/Auth Boundary` は auth/session 境界の出力を正規化してよいが、token verification や provider policy 自体を再定義してはならない
- `Command Intake` は `Query Read` の completed result contract を内包してはならない
- `Query Read` は workflow 起動や retry dispatch を own してはならない
- `Async Generation` は incomplete payload を user-facing contract として返してはならない
- `External Adapters` は top-level responsibility として単独で存在するが、最終的な受理判断や表示判断は持ってはならない

## Architecture Style Rule

- 主軸はオニオンアーキテクチャであり、top-level 責務は外から見える component catalog である
- `Domain Core` と `Application Coordination` は foundation layer として明示するが、現行 component の割り当て先としては使わない
- `auth/session` は outer boundary として 009 から分離し、境界の利用点だけを `Actor/Auth Boundary` に表す
