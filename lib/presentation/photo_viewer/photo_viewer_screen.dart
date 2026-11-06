import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// A-5-3 사진 크게 보기. 핀치 줌 · 좌우 스와이프.
class PhotoViewerScreen extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.urls.length;
    return Scaffold(
      backgroundColor: ColorConfig.bgPhotoViewer,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                AppIconButton(
                  icon: AppIcons.close,
                  color: ColorConfig.textOnDark,
                  semanticLabel: '닫기',
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_index + 1} / $count',
                      style: TextConfig.numberM.copyWith(
                        color: ColorConfig.textOnDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 52),
              ],
            ),
            Expanded(
              child: PhotoViewGallery.builder(
                pageController: _controller,
                itemCount: count,
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(
                  color: ColorConfig.bgPhotoViewer,
                ),
                onPageChanged: (i) => setState(() => _index = i),
                builder: (context, index) => PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(widget.urls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
                loadingBuilder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: ColorConfig.brandBlue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48, top: 12),
              child: Column(
                children: [
                  if (count > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < count; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _index
                                  ? ColorConfig.textOnDark
                                  : ColorConfig.textOnDark.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 12),
                  Text(
                    '두 손가락으로 확대하고, 옆으로 넘겨 다음 사진을 볼 수 있어요',
                    style: TextConfig.caption.copyWith(
                      color: ColorConfig.textOnDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
