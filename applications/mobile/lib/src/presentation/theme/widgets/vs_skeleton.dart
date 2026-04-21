import 'package:flutter/material.dart';

import '../vs_tokens.dart';

/// Shimmer placeholder mirroring the handoff bundle's `VSSkeleton`.
class VsSkeleton extends StatefulWidget {
  const VsSkeleton({
    this.width,
    this.height = 12,
    this.radius = VsTokens.radiusSm,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<VsSkeleton> createState() => _VsSkeletonState();
}

class _VsSkeletonState extends State<VsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: VsTokens.shimmerDuration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final phase = _controller.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(phase - 1, 0),
              end: Alignment(phase + 1, 0),
              colors: const <Color>[
                VsTokens.paperDeep,
                VsTokens.paperSoft,
                VsTokens.paperDeep,
              ],
              stops: const <double>[0, 0.5, 1],
            ),
          ),
        );
      },
    );
  }
}
