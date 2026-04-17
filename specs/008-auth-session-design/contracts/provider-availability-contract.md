# Contract: Provider Availability

## Purpose

provider ごとの初期対象、条件付き対象、利用不可条件を固定する。

## Provider Policy

| Provider | Initial Tier | Enable When | Disable When | Fallback Guidance |
|----------|--------------|-------------|--------------|------------------|
| `Basic` | `baseline` | Firebase Authentication で email/password 登録と本人確認が提供可能 | 基本 credential 運用自体を採用しない場合 | 他の baseline provider を案内する |
| `Google` | `baseline` | Firebase Authentication 経由で Google sign-in と backend token verification が利用可能 | provider 障害または運用停止 | `Basic` を案内する |
| `Apple ID` | `conditional` | Firebase Authentication または同等の接続経路で追加の直接費用や必須運用負荷が発生しない | 追加コストまたは運用条件が発生する | `Basic` または `Google` を案内する |
| `LINE` | `conditional` | Firebase Authentication 連携または同等の接続経路で追加の直接費用や必須運用負荷が発生しない | 追加コストまたは運用条件が発生する | `Basic` または `Google` を案内する |

## Policy Rules

- `Basic` と `Google` は初期リリースで Firebase Authentication 経由により利用可能でなければならない
- `Apple ID` と `LINE` は、追加コストなし条件を満たすまで初期対象に含めてはならない
- 利用不可の provider は案内上で無効または非表示とし、成立しない導線を見せてはならない
