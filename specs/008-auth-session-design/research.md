# Research: 会員登録・ログイン・ログアウト設計

## Decision: 認証は vocastock のコアドメイン外に置き、アプリ本体へは正規化済み actor reference のみを渡す

**Rationale**: 認証そのものを語彙学習ドメインへ持ち込むと、外部 identity、credential、
session 管理が学習概念と混線する。アプリ本体は認証詳細を知らず、正規化済みの
actor reference を受け取って保護操作を判断する方が、責務分離と provider 差し替えに向く。

**Alternatives considered**:

- 認証 account をコアドメイン aggregate として扱う
- provider ごとの認証情報をアプリ本体へ直接渡す

## Decision: 認証 UI と provider 開始は Flutter client が担い、本人確認基盤は Firebase Authentication を使う

**Rationale**: メール入力、Google sign-in 開始、ログアウト導線の UX は Flutter 側に
置く方がモバイルアプリとして自然で、provider 固有 SDK や Firebase client SDK の責務とも
整合する。一方で credential 検証や provider セッションの正当性は Firebase
Authentication に委ねる方が、複数 provider を同じ認証基盤で扱いやすい。

**Alternatives considered**:

- 認証 UI も provider 開始も backend 主導の web flow に寄せる
- `Basic` / `Google` / `Apple` / `LINE` を Firebase ではなく個別基盤で別々に扱う

## Decision: backend は Flutter から受け取った Firebase ID token を検証してから、Firebase subject を actor / learner へ解決する

**Rationale**: Flutter で Firebase sign-in が成功しただけでは、アプリ本体で利用可能な
actor が確定したことにはならない。backend が ID token を検証し、検証済み Firebase
subject から actor / learner を解決して初めて、保護操作へ進める状態を安全に定義できる。

**Alternatives considered**:

- Flutter 側の `FirebaseUser` だけを信用して app core を通す
- backend で token 検証をせず、client が送る uid 文字列をそのまま actor 解決に使う

## Decision: 初期対象は `Basic` と `Google` とし、`Apple ID` と `LINE` は追加コストなしの場合のみ候補とする

**Rationale**: 初期導線として最低限の認証手段を確保しつつ、provider 数を増やしすぎない方が
設計と運用を単純にできる。`Apple ID` と `LINE` は利用価値がある一方で、追加の運用費、
契約費、審査負荷が発生する可能性があるため、追加コストがない場合のみ後続候補として扱う。

**Alternatives considered**:

- 初期対象に `Apple ID` と `LINE` も含める
- `Basic` のみを初期対象にする

## Decision: 会員登録、ログイン、ログアウト、session handoff、actor resolution を別責務として整理する

**Rationale**: 会員作成、本人確認、session 付与、利用主体解決はそれぞれ失敗条件と完了条件が
異なる。1 つの責務にまとめると部分成功時の扱いが曖昧になるため、責務を分割して contract を
定義する方が検証しやすい。

**Alternatives considered**:

- 会員登録とログインを単一責務として扱う
- session handoff をアプリ本体側の暗黙処理にする

## Decision: app core は actor reference だけを受け取り、Firebase token、`FirebaseUser`、provider credential を保持しない

**Rationale**: app core が Firebase Authentication の詳細を知ると、認証境界と
学習ドメインの責務が再び混線する。app core が受け取るのを actor reference と最小限の
利用可否状態だけに限定すれば、認証基盤の差し替えや provider の増減が起きても影響範囲を
auth boundary 内へ閉じ込めやすい。

**Alternatives considered**:

- app core が Firebase ID token を直接保持する
- app core が provider 名や raw user profile を前提に分岐する

## Decision: 重複会員は作成せず、既存会員案内または既存 identity への接続へ寄せる

**Rationale**: 同じメールアドレスや同じ provider subject で重複会員を作ると、利用主体解決と
保護操作の整合が崩れる。重複検知時は既存会員の再利用または案内に寄せることで、利用主体を
一意に保てる。

**Alternatives considered**:

- 重複時も別会員として作成する
- 常にエラーのみ返し、既存会員案内を行わない

## Decision: 部分的に成立した認証状態は成功として返さない

**Rationale**: 認証成功後に session 発行や actor resolution が失敗した状態を「利用可能」と
見せると、後続操作で不整合が起きる。会員登録、ログイン、ログアウトのいずれでも、利用者に
成功を返すのは必要な後続条件まで満たした場合だけに限定する。

**Alternatives considered**:

- 認証成功だけで利用可能状態を返し、後続補正に委ねる
- 部分成功を暫定状態として画面へ見せる

## Decision: ログアウトは active session の失効と protected operation の再認証要求をセットで定義する

**Rationale**: ログアウトを UI 上の見かけの状態変更だけにすると、保護操作の可用性が曖昧に
残る。session 失効と再認証要求を一体で定義することで、ログアウト完了の意味を固定できる。

**Alternatives considered**:

- ログアウトはクライアントの状態破棄だけで扱う
- session の自然失効だけに依存する

## Decision: logout は Flutter 側の Firebase sign-out と backend 側の app-session 終了をセットで定義する

**Rationale**: Flutter 側だけで sign-out しても、backend 側の利用可能状態や actor handoff
条件が残ると保護操作の意味が曖昧になる。Firebase Auth current user の解除と app-session
終了をセットで定義することで、logout 完了の判定と再認証要求を一貫して扱える。

**Alternatives considered**:

- Flutter 側の Firebase sign-out のみで logout 完了とする
- backend 側の session だけを終了し、client 側の Firebase sign-out を任意にする
