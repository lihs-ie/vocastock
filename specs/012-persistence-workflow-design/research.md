# Research: 永続化 / Read Model と非同期 Workflow 設計

## Decision: authoritative write store と app-facing read projection を分離する

**Rationale**: aggregate の不変条件と user-facing 表示責務を同じ保存面に載せると、
current pointer、status-only 表示、stale read の議論が混ざる。write-side は aggregate /
runtime state の正本、read-side は app-facing projection として分けた方が 009 の
`Command Intake` / `Query Read` 分離とも整合する。

**Alternatives considered**:

- 単一の汎用 document / table に write-side と read-side を同居させる
- projection を持たず、常に複数 aggregate を join して返す

## Decision: workflow runtime state は domain-facing status より細かく持つ

**Rationale**: domain docs は `pending`、`running`、`succeeded`、`failed` を正本としているが、
実運用では `retry-scheduled`、`timed-out`、`failed-final`、`dead-lettered` を区別しないと
timeout と exhaustion を説明できない。したがって runtime state は richer に持ち、
user-facing projection には既存 status へ正規化して返す。

**Alternatives considered**:

- runtime state も `pending/running/succeeded/failed` の 4 状態だけにする
- runtime state を持たず aggregate status だけで retry / timeout を表現する

## Decision: current pointer は aggregate 側に残し、read model はそれを参照して組み立てる

**Rationale**: `VocabularyExpression.currentExplanation` と `Explanation.currentImage` は domain の
表示規則そのものであり、projection 側で独自に current 判定すると整合が崩れる。current 切替は
authoritative aggregate 更新で行い、projection はその結果を参照する。

**Alternatives considered**:

- read model 側で最新成功レコードを current とみなす
- workflow runtime state だけから current を決める

## Decision: workflow attempt record を aggregate 本体から分離する

**Rationale**: retry 回数、timeout、next retry、failure class は aggregate の本質情報ではなく
runtime 運用情報である。aggregate に埋め込むと domain semantics が膨らむため、
`WorkflowAttemptRecord` を別の authoritative runtime store に分離する。

**Alternatives considered**:

- `VocabularyExpression` と `Explanation` の中へ retry 回数や timeout を埋め込む
- workflow attempt を永続化せず、外部 runner の内部状態だけに依存する

## Decision: partial success は completed projection を進めず、status-only に倒す

**Rationale**: `Explanation` 作成成功と `VisualImage` 保存失敗、purchase verification timeout と
notification 到着前の状態などは、内部では一部成功でも user-facing には completed result として
見せられない。projection は completed 要件を満たすまで status-only に留める。

**Alternatives considered**:

- 部分成功をそのまま completed として表示する
- 部分成功時に projection 自体を消す

## Decision: timeout 後は新しい成功を合成せず、既存 completed projection または mirror を維持する

**Rationale**: timeout は成功保証ではない。新しい completed result を作らず、既存の
`currentExplanation` / `currentImage` / entitlement mirror があれば保持し、なければ status-only を返す。
これにより 010 の `pending-sync` rule と 011 の visible summary rule を壊さない。

**Alternatives considered**:

- timeout を暫定成功として projection へ反映する
- timeout のたびに既存 completed projection を削除する

## Decision: dead-letter 相当は operator review 用の終端状態として別 store に退避する

**Rationale**: retry exhaustion 後の失敗を通常の `failed` と同一視すると、人手レビューが必要な案件を
埋もれさせやすい。`DeadLetterReviewUnit` を別 persistence allocation として持ち、end-user には
status-only failure を返し、運用側には review 対象として見せる。

**Alternatives considered**:

- exhaustion 後も通常の `failed` に留める
- 自動 retry を無制限に続ける

## Decision: purchase state と authoritative subscription state は別 store / 別 state model とする

**Rationale**: 010 で purchase state と subscription state は別概念と決めている。restore や
notification reconciliation を扱うときも、purchase artifact の受理 / 検証状態と premium unlock の
最終正本を混同しないよう分離を維持する。

**Alternatives considered**:

- purchase state と subscription state を 1 つの state machine に統合する
- purchase state を保存せず subscription state だけを残す

## Decision: entitlement snapshot と usage allowance は別 persistence allocation とする

**Rationale**: entitlement は「何が使えるか」、usage allowance は「どれだけ残っているか」であり、
010 で別責務とされている。projection では並べて見せても、write-side と authoritative source は分ける。

**Alternatives considered**:

- entitlement と usage allowance を同一レコードに埋め込む
- allowance を projection だけに持ち、write-side 正本を持たない

## Decision: restore は purchase verification と同じ終端を書き込むが、別 workflow として追跡する

**Rationale**: restore は purchase artifact の新規受付ではなく、既存 purchase / subscription を
再照合するフローである。結果として purchase state や subscription state を更新しても、
runtime trace は別 workflow として持つ方が障害解析しやすい。

**Alternatives considered**:

- restore を purchase verification の単なる reason として吸収する
- restore を query refresh と同一視する

## Decision: notification reconciliation は purchase / restore より低優先の fallback 更新路とする

**Rationale**: store notification は authoritative 更新に使えるが、遅延や欠落がありうる。
既存 mirror を上書きして誤って paid entitlement を付与しないよう、notification は
補正・追随の workflow と位置付ける。

**Alternatives considered**:

- notification を常に最優先の authoritative source とする
- notification を一切保存しない
