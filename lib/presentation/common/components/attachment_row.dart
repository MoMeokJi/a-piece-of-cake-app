import 'package:cake/domain/model/local_image.dart';
import 'package:cake/ui/common_components/photo_thumb.dart';
import 'package:flutter/material.dart';

/// 첨부 사진 썸네일 줄. [onAdd]를 주면 마지막에 추가 버튼.
class AttachmentRow extends StatelessWidget {
  final List<LocalImage> images;
  final int max;
  final ValueChanged<int> onRemove;
  final VoidCallback? onAdd;

  const AttachmentRow({
    super.key,
    required this.images,
    required this.max,
    required this.onRemove,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty && onAdd == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (var i = 0; i < images.length; i++) ...[
              PhotoThumb.file(images[i].path, onRemove: () => onRemove(i)),
              const SizedBox(width: 8),
            ],
            if (onAdd != null && images.length < max)
              PhotoAddThumb(current: images.length, max: max, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}
