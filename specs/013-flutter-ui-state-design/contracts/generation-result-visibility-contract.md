# Contract: Generation Result Visibility

## Purpose

generation status 集約画面と completed result detail 画面の visibility rule を固定する。

## Screen Visibility Matrix

| Screen | Allowed Payload | Status States | Prohibited Display |
|--------|-----------------|---------------|--------------------|
| `VocabularyExpressionDetail` | explanation / image の summary と status | `pending`、`running`、`retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered`、completed summary | explanation 本文、未完了 image payload、複数 current image |
| `ExplanationDetail` | completed explanation 本文 | completed のみ | pending / failed explanation payload |
| `ImageDetail` | completed `Explanation.currentImage` | completed のみ | 未保存 image、partial success、複数 current image |

## Visibility Rules

- completed explanation は `currentExplanation` が authoritative current pointer として確定した後にだけ表示できる
- completed image は `currentImage` が authoritative current pointer として確定した後にだけ表示できる
- stale read 中は loading または status-only に倒してよいが、completed と見せてはならない
- image retry / regenerate 中でも既存 completed current image がある場合は、それを維持してよい
- new completed result が確定する前に preview や intermediate payload を表示してはならない
