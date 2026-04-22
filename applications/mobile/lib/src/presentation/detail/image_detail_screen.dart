import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_bindings.dart';
import '../../domain/identifier/identifier.dart';
import '../theme/vs_tokens.dart';
import '../theme/widgets/vs_illustration_panel.dart';
import '../theme/widgets/vs_section_label.dart';
import '../theme/widgets/vs_skeleton.dart';
import '../theme/widgets/vs_wordmark.dart';

/// Spec 013 canonical `ImageDetail` screen.
///
/// Visual reference: `screens.jsx` enlarged `DetailImagePanel`. The
/// completed image is shown as a swipeable gallery of 3 seed-varied
/// panels (stand-in for spec 017 multi-image payloads); the associated
/// sense label is overlayed top-left and a refresh button cycles to the
/// next variant. Null payloads pop back without flashing
/// (`allowsCompletedPayload = true`).
class ImageDetailScreen extends ConsumerStatefulWidget {
  const ImageDetailScreen({required this.identifier, super.key});

  final VisualImageIdentifier identifier;

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  static const int _totalImages = 3;

  late final PageController _controller;
  int _imageIdx = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _imageIdx = index);
    if (_controller.hasClients) {
      unawaited(
        _controller.animateToPage(
          index,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(imageDetailFutureProvider(widget.identifier));
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final panelHeight = size.height * 0.5;

    return Scaffold(
      backgroundColor: VsTokens.paper,
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.pop();
              });
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: const Text('戻る'),
                        style: TextButton.styleFrom(
                          foregroundColor: VsTokens.inkSoft,
                          textStyle: const TextStyle(
                            fontFamily: VsTokens.sans,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const VsWordmark(size: 13),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: VsTokens.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 0.5, height: 0.5),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: <Widget>[
                      SizedBox(
                        key: const Key('image-detail.asset'),
                        height: panelHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            PageView.builder(
                              key: const Key('image-detail.pager'),
                              controller: _controller,
                              itemCount: _totalImages,
                              onPageChanged: (idx) =>
                                  setState(() => _imageIdx = idx),
                              itemBuilder: (_, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      VsTokens.radiusLg,
                                    ),
                                    border: Border.all(
                                      color: VsTokens.inkHair,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: VsIllustrationPanel(
                                    seed: widget.identifier.value.length +
                                        index,
                                    label:
                                        '${detail.senseLabel ?? '視覚イメージ'} ${index + 1}',
                                    height: panelHeight,
                                    borderRadius: VsTokens.radiusLg,
                                  ),
                                );
                              },
                            ),
                            if (detail.senseLabel != null)
                              Positioned(
                                left: 16,
                                top: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: VsTokens.ink.withAlpha(210),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    detail.senseLabel!,
                                    key: const Key(
                                      'image-detail.sense-label',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: VsTokens.sans,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: VsTokens.paper,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Material(
                                color: VsTokens.paper.withAlpha(220),
                                shape: const CircleBorder(
                                  side: BorderSide(
                                    color: VsTokens.inkHair,
                                    width: 0.5,
                                  ),
                                ),
                                child: InkWell(
                                  key: const Key('image-detail.refresh'),
                                  customBorder: const CircleBorder(),
                                  onTap: () => _goTo(
                                    (_imageIdx + 1) % _totalImages,
                                  ),
                                  child: const SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Icon(
                                      Icons.refresh,
                                      size: 18,
                                      color: VsTokens.inkSoft,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (var i = 0; i < _totalImages; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => _goTo(i),
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  width: i == _imageIdx ? 22 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _imageIdx
                                        ? VsTokens.ink
                                        : VsTokens.inkHair,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const VsSectionLabel('DESCRIPTION'),
                            const SizedBox(height: 6),
                            Text(
                              detail.description,
                              key: const Key('image-detail.description'),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.7,
                                color: VsTokens.ink,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              detail.assetReference,
                              style: const TextStyle(
                                fontFamily: VsTokens.mono,
                                fontSize: 10,
                                letterSpacing: 0.3,
                                color: VsTokens.inkMute,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const _LoadingBody(),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VsTokens.accentSoft,
                  borderRadius: BorderRadius.circular(VsTokens.radiusMd),
                ),
                child: Text(
                  'エラーが発生しました: $error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: VsTokens.err,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('image-detail.loading'),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: const <Widget>[
        VsSkeleton(height: 280, radius: VsTokens.radiusLg),
        SizedBox(height: 20),
        VsSkeleton(),
        SizedBox(height: 6),
        VsSkeleton(width: 200),
      ],
    );
  }
}
