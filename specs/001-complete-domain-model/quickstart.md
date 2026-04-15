# Quickstart: ドメインモデル設計書の完成

## 1. 計画成果物を確認する

- `spec.md` で feature の目的と受け入れ条件を確認する
- `research.md` で採用したモデリング判断を確認する
- `data-model.md` で追加・再定義する集約、値オブジェクト、状態、イベントを確認する
- `contracts/` で外部ポート契約と表示契約を確認する

## 2. ドメイン文書を更新する

- `docs/internal/domain/common.md` に共通状態や学習進捗で再利用する概念を追加する
- `docs/internal/domain/explanation.md` に `VocabularyEntry`、`Explanation`、
  生成状態、関連イベントを反映する
- `docs/internal/domain/visual.md` に `VisualImage` の永続化参照と関係を反映する
- `docs/internal/domain/service.md` に外部ポートとして扱う責務を反映する

## 3. 外部文書を同期する

- `docs/external/requirements.md` の用語が新しいドメイン境界と一致するか確認する
- `docs/external/adr.md` のコンポーネント責務がポート設計と矛盾しないか確認する

## 4. 完了条件を検証する

- 登録状態、解説生成状態、画像生成状態が別概念として説明できる
- 完了済み結果のみを表示するルールが明文化されている
- 外部 AI、画像保存、発音参照、単語検証がポートとして整理されている
- 識別子型が `XxxIdentifier`、集約自身の識別子が `identifier`、関連参照が概念名で統一されている
- `Explanation` と `VisualImage` の責務重複が解消されている
- 要件文書、ADR、ドメイン文書で主要用語の矛盾がない
