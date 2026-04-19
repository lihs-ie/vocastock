# Contract: Feature Gate Matrix

## Purpose

plan tier と subscription state に応じた feature gate outcome を固定する。

## Canonical Feature Keys

- `catalog-viewing`
- `vocabulary-registration`
- `explanation-generation`
- `image-generation`
- `completed-result-viewing`
- `subscription-status-access`
- `restore-access`

## Gate Matrix

| Feature Key | Free | Paid Active | Paid Grace | Pending Sync | Expired | Revoked |
|-------------|------|-------------|------------|--------------|---------|---------|
| `catalog-viewing` | `allow` | `allow` | `allow` | `allow` | `allow` | `deny` |
| `vocabulary-registration` | `allow` | `allow` | `allow` | `allow` | `allow` | `deny` |
| `explanation-generation` | `limited` | `allow` | `allow` | `limited` | `limited` | `deny` |
| `image-generation` | `limited` | `allow` | `allow` | `limited` | `limited` | `deny` |
| `completed-result-viewing` | `allow` | `allow` | `allow` | `allow` | `allow` | `deny` |
| `subscription-status-access` | `allow` | `allow` | `allow` | `allow` | `allow` | `allow` |
| `restore-access` | `allow` | `allow` | `allow` | `allow` | `allow` | `allow` |

## Outcome Rules

- `limited` は quota 残量に応じて実行可否を最終判定する
- `pending-sync` は paid unlock を与えず、free-safe baseline に倒す
- `expired` は free baseline に戻しつつ upsell / recovery を出してよい
- `revoked` は hard-stop とし、recovery 以外の通常利用を止める

## Invariants

- `pending-sync` を `allow` として premium generation を通してはならない
- `expired` は paid active より強い outcome を返してはならない
- `revoked` で `subscription-status-access` と `restore-access` 以外を `allow` にしてはならない
