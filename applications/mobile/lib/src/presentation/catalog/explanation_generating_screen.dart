import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/router.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_chip.dart';
import '../theme/widgets/vs_progress.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_skeleton.dart';
import '../theme/widgets/vs_stage_step.dart';

/// Mirror of `screens.jsx` `VSAddGenerating`.
///
/// Plays through five generation stages (normalize → sense extraction →
/// frequency/sophistication → examples → etymology), each lasting 900ms.
/// A skeleton preview hints at the completed Explanation. When the last
/// stage finishes the screen auto-advances to `/catalog` after a 700ms
/// pause.
class ExplanationGeneratingScreen extends StatefulWidget {
  const ExplanationGeneratingScreen({required this.text, super.key});

  final String text;

  @override
  State<ExplanationGeneratingScreen> createState() =>
      _ExplanationGeneratingScreenState();
}

class _ExplanationGeneratingScreenState
    extends State<ExplanationGeneratingScreen> {
  static const List<_Stage> _stages = <_Stage>[
    _Stage(label: '正規化', sub: '表記ゆれを判定しています'),
    _Stage(label: 'Sense 抽出', sub: '意味単位を検出しています'),
    _Stage(
      label: 'Frequency / Sophistication',
      sub: '頻出度と難度を評価中',
    ),
    _Stage(label: '例文生成', sub: 'Sense ごとに例文を構成'),
    _Stage(label: '語源・類似表現', sub: '補助情報を組み立てています'),
  ];

  int _stageIdx = 0;
  bool _done = false;
  Timer? _tickTimer;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 900), _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    if (_stageIdx < _stages.length - 1) {
      setState(() => _stageIdx += 1);
    } else if (!_done) {
      setState(() => _done = true);
      timer.cancel();
      _exitTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          GoRouter.of(context).go(AppRoutes.catalog);
        });
      });
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  double get _progress =>
      _done ? 1 : (_stageIdx + 0.5) / _stages.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.catalog),
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('戻る'),
                    style: TextButton.styleFrom(
                      foregroundColor: VsTokens.inkSoft,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const VsChip(
                    label: '生成中',
                    tone: VsChipTone.accent,
                    icon: Icon(Icons.circle, size: 8),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const VsSectionLabel(
                'ExplanationGenerationStatus: running',
              ),
              const SizedBox(height: 6),
              Text(
                widget.text,
                key: const Key('generating.text'),
                style: const TextStyle(
                  fontFamily: VsTokens.serif,
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                  height: 1,
                  color: VsTokens.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '/…/',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: VsTokens.mono,
                  fontSize: 12,
                  color: VsTokens.inkMute,
                ),
              ),
              const SizedBox(height: 24),
              VsProgress(value: _progress),
              const SizedBox(height: 24),
              Column(
                children: <Widget>[
                  for (var i = 0; i < _stages.length; i++)
                    VsStageStep(
                      state: _stateFor(i),
                      label: _stages[i].label,
                      sub: _stages[i].sub,
                      isLast: i == _stages.length - 1,
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const _SkeletonPreview(),
            ],
          ),
        ),
      ),
    );
  }

  // end build

  VsStageState _stateFor(int index) {
    if (_done) return VsStageState.done;
    if (index < _stageIdx) return VsStageState.done;
    if (index == _stageIdx) return VsStageState.active;
    return VsStageState.pending;
  }
}

@immutable
class _Stage {
  const _Stage({required this.label, required this.sub});
  final String label;
  final String sub;
}

class _SkeletonPreview extends StatelessWidget {
  const _SkeletonPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VsTokens.paperSoft,
        border: Border.all(color: VsTokens.inkHair),
        borderRadius: BorderRadius.circular(VsTokens.radiusMd),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VsSectionLabel('プレビュー（完了時に表示）'),
          SizedBox(height: 12),
          VsSkeleton(width: 180, height: 14),
          SizedBox(height: 8),
          VsSkeleton(height: 8),
          SizedBox(height: 4),
          VsSkeleton(width: 280, height: 8),
          SizedBox(height: 12),
          Row(
            children: <Widget>[
              VsSkeleton(width: 44, height: 16, radius: 8),
              SizedBox(width: 6),
              VsSkeleton(width: 52, height: 16, radius: 8),
              SizedBox(width: 6),
              VsSkeleton(width: 40, height: 16, radius: 8),
            ],
          ),
          SizedBox(height: 14),
          Text(
            '要件：中間生成結果は表示せず、完了時のみ切り替わります。',
            style: TextStyle(
              fontFamily: VsTokens.sans,
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: VsTokens.inkMute,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
