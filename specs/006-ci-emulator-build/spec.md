# Feature Specification: CI Emulator Build Optimization

**Feature Branch**: `006-ci-emulator-build`  
**Created**: 2026-04-16  
**Status**: Draft  
**Input**: User description: "CI では --build を外し、image を再利用する emulator image の build を別 step / 別 workflow に分離する Docker layer cache か事前配布 image を使う start_emulators.sh に build/start の詳細ログを追加して、次回は停止点を即座に見えるようにする"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reuse Prepared Emulator Image (Priority: P1)

CI 管理者として、Firebase emulator smoke 実行時に毎回 image を作り直さず、準備済み image を再利用したい。これにより、required check の待ち時間を減らし、runner ごとの build ばらつきで merge が止まる状態を避けたい。

**Why this priority**: 現在の blocker は emulator smoke の長時間化であり、required check の信頼性を回復する価値が最も高い。

**Independent Test**: emulator smoke を単独で実行し、baseline 更新がない run では smoke job 内で image build を要求せずに ready 判定まで進めば、このストーリーだけで価値を示せる。

**Acceptance Scenarios**:

1. **Given** emulator image が事前に利用可能な状態で、**When** CI の emulator smoke が始まる、**Then** smoke 実行は準備済み image を使って開始し、同じ run の中で image build を必須にしない。
2. **Given** reusable image が利用できない状態で、**When** emulator smoke が始まる、**Then** CI は fallback 挙動を明示し、失敗または代替経路の理由をログへ残す。

---

### User Story 2 - Separate Image Preparation From Smoke Execution (Priority: P2)

CI 管理者として、emulator image の build と smoke 実行を別 step または別 workflow に分けたい。これにより、baseline 変更時の rebuild と通常の smoke 実行を切り分けて運用したい。

**Why this priority**: build と smoke を分離すると、ボトルネックの局所化と cache 戦略の適用がしやすくなる。

**Independent Test**: image preparation path と smoke path が独立に実行でき、smoke path が image 参照だけで成立すれば、このストーリーは単独で検証できる。

**Acceptance Scenarios**:

1. **Given** emulator image baseline が更新された、**When** image preparation path が実行される、**Then** build/publish/caching に必要な成果物が次の smoke 実行から参照できる。
2. **Given** baseline に変更がない、**When** smoke 実行だけを起動する、**Then** image preparation path を毎回再実行しなくても required check が成立する。

---

### User Story 3 - Diagnose Emulator Startup Delays Quickly (Priority: P3)

CI 管理者として、emulator 関連 check が遅いまたは失敗したときに、build、pull、container start、ready wait のどこで止まったかをログから即座に判断したい。

**Why this priority**: 再発時に停止点が読めないと、最適化後も調査時間が長く残るため。

**Independent Test**: 成功時と失敗時のログを見て、どの段階で時間を使ったかを第三者が 5 分以内に説明できれば、このストーリーは単独で有効である。

**Acceptance Scenarios**:

1. **Given** emulator smoke が成功した、**When** 担当者がログを確認する、**Then** image resolution、build/pull、container start、ready 判定の順序と経過時間を追跡できる。
2. **Given** emulator smoke が失敗した、**When** 担当者がログを確認する、**Then** build、pull、container start、ready wait のどこで停止したかを追加調査なしで判定できる。

### Edge Cases

- reusable image の参照先が存在しない場合、smoke path は無言で待ち続けず、fallback または failure reason を明示すること
- baseline 更新直後に cache miss が起きても、どの key または image 参照が無効化されたかを記録すること
- pull request と branch push が並行して走っても、別 run の image 状態を誤って前提にしないこと
- ready 判定前に container が落ちた場合、単なる timeout と区別できるログを残すこと

## Domain & Async Impact *(mandatory when applicable)*

- **Domain Models Affected**: None
- **Invariants / Terminology**: local host baseline、CI runner baseline、emulator image preparation、emulator smoke execution、ready budget を別概念として扱い、混同しない
- **Async Lifecycle**: image preparation と smoke execution はそれぞれ `pending/running/succeeded/failed` を持ち、同じ baseline 参照に対する再試行は idempotent でなければならない
- **User Visibility Rule**: merge 可否の判断には completed な required checks のみを使い、進行中は状態のみを示す
- **Identifier Naming Rule**: 新しい domain identifier type は追加しない
- **External Ports / Adapters**: GitHub Actions workflow、Docker image cache or distribution path、Firebase emulator container startup script、CI artifact logging

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow emulator smoke checks to reuse a prepared emulator image path when the approved baseline has not changed.
- **FR-002**: System MUST separate emulator image preparation from emulator smoke execution as distinct operational units so that normal smoke runs do not require an inline image rebuild.
- **FR-003**: System MUST support either a cache-backed path or a pre-distributed image path that works on clean CI runners.
- **FR-004**: System MUST record which image source was used for each smoke execution, including cache hit, pre-distributed image use, or fallback behavior.
- **FR-005**: System MUST fail deterministically when the reusable image path is unavailable or stale and MUST explain the failure reason in logs.
- **FR-006**: System MUST emit stage-specific logs for image resolution, image build or pull, container startup, and readiness waiting.
- **FR-007**: System MUST keep the local developer path usable even when reusable CI image paths are not available.
- **FR-008**: System MUST preserve existing required-check names and merge-protection behavior while optimizing the emulator path.
- **FR-009**: System MUST document the source of truth for emulator image baseline, invalidation triggers, and ownership of the preparation path.
- **FR-010**: System MUST measure and report the runtime impact of the optimized emulator path against the existing readiness and aggregate CI budgets.

### Key Entities *(include if feature involves data)*

- **Emulator Image Baseline**: reusable emulator image reference, its validity window, and the change conditions that require rebuild or invalidation
- **Image Preparation Execution**: one operational run that creates, refreshes, caches, or publishes the emulator image for later smoke jobs
- **Emulator Smoke Execution**: one required-check run that consumes the prepared image, starts the emulator container, and waits for readiness
- **CI Diagnostic Log Bundle**: structured log output that records each stage and enough context to identify where delays or failures occurred

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For runs without baseline changes, at least 95% of emulator smoke executions start from a reusable image path without performing an inline image rebuild.
- **SC-002**: On reusable-image runs, emulator smoke reaches ready state within 5 minutes.
- **SC-003**: 95% of full required-check runs that include emulator smoke complete within the existing aggregate CI budget.
- **SC-004**: In 100% of failed emulator smoke runs, maintainers can identify whether the stop occurred during image resolution, build or pull, container startup, or readiness waiting from the recorded logs alone.

## Assumptions

- GitHub Actions remains the repository's required-check execution environment.
- Firebase emulator remains part of the required-check path and is not being removed or replaced by an external hosted service in this feature.
- Existing required-check names and branch protection remain in force; this feature optimizes execution flow rather than reducing coverage.
- Reusable image distribution may be satisfied by cache, prebuilt image, or both, as long as the chosen path is documented and operationally consistent.
