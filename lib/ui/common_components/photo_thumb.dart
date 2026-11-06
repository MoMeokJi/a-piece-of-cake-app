import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 첨부 사진 썸네일. 기본 76×76, 모서리 16.
/// - [PhotoThumb.network] / [PhotoThumb.file]: 보기 전용. [onRemove]를 주면 우상단 삭제 배지.
/// - [PhotoThumb.add]: 점선 추가 버튼 (현재/최대).
class PhotoThumb extends StatelessWidget {
  final String? url;
  final String? filePath;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final double size;
  final double radius;

  const PhotoThumb.network(
    this.url, {
    super.key,
    this.onTap,
    this.onRemove,
    this.size = 76,
    this.radius = AppRadius.lg,
  }) : filePath = null;

  const PhotoThumb.file(
    this.filePath, {
    super.key,
    this.onTap,
    this.onRemove,
    this.size = 76,
    this.radius = AppRadius.lg,
  }) : url = null;

  @override
  Widget build(BuildContext context) {
    final image = filePath != null
        ? Image.file(File(filePath!), fit: BoxFit.cover)
        : (url != null && url!.startsWith('http'))
        ? CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(
              color: ColorConfig.bgPlaceholder,
            ),
            errorWidget: (_, _, _) => const _BrokenImage(),
          )
        : const ColoredBox(color: ColorConfig.bgPlaceholder);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: ColoredBox(
                  color: ColorConfig.bgPlaceholder,
                  child: image,
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ColorConfig.removeBadge,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorConfig.bgPage, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const AppIcon(
                    AppIcons.close,
                    size: 12,
                    color: ColorConfig.textOnDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PhotoAddThumb extends StatelessWidget {
  final int current;
  final int max;
  final VoidCallback? onTap;
  final double size;

  const PhotoAddThumb({
    super.key,
    required this.current,
    required this.max,
    required this.onTap,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: ColorConfig.borderFocus,
          radius: AppRadius.lg,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ColorConfig.bgSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon(
                AppIcons.plus,
                size: 22,
                color: ColorConfig.textAccent,
              ),
              const SizedBox(height: 2),
              Text(
                '$current/$max',
                style: TextConfig.numberS.copyWith(
                  color: ColorConfig.textAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: ColorConfig.bgPlaceholder,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: ColorConfig.textDisabled,
          size: 18,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect.deflate(0.75));
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
