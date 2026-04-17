# Contract: Command Boundary

## Purpose

backend command 境界が直接持つ責務、持たない責務、依存する境界を固定する。

## Responsibility Split

| Boundary | Owns | Must Not Own | Depends On |
|----------|------|--------------|------------|
| Backend Command | 登録、生成開始、再試行の受理、前提条件確認、重複判定、即時応答 | 長時間生成処理、read model 整形、provider SDK 直結 | validation port、repository port、workflow dispatch port、authentication subject resolution |
| Query | 表示用 read model の組み立て | 状態変更、生成開始受理 | projection / repository |
| Workflow | 長時間生成処理、状態遷移、完了 / 失敗確定 | command 受理判断、利用者入力の解釈 | provider port、storage port |
| Client | command 起動と状態表示 | backend 内部状態判断、provider 直結 | command contract、query contract |

## Port Rules

- `WordValidationPort` は command 受理前の副作用なし検証だけに使う
- repository port は command 側の状態確認と状態確定に限定して使う
- workflow dispatch port は command 受理確定の一部であり、成功しない限り `pending` を確定しない
- provider 個別実装や storage 個別実装は command 境界へ持ち込まない

## Out of Scope

- query schema や read model 詳細
- workflow 実行本体の state machine
- provider ごとの request / response 詳細
- infrastructure adapter の実装方式
