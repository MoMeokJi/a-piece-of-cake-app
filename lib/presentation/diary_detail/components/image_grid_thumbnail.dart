import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/diary_detail.dart';
import 'package:cake/presentation/diary_detail/components/photo_view_dialog.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class ImageGridThumbnail extends StatelessWidget {
  final DiaryDetail diary;

  const ImageGridThumbnail({super.key, required this.diary});

  String _getImageUrl(int index) {
    if (index < diary.imageUrls.length) {
      return diary.imageUrls[index];
    }

    final position = index + 1;
    if (position % 2 == 1) {
      return 'assets/images/blueberry_blur.png';
    } else {
      return 'assets/images/strawberry_blur.png';
    }
  }

  bool _isRealImage(int index) {
    return index < diary.imageUrls.length;
  }

  @override
  Widget build(BuildContext context) {
    if (diary.imageUrls.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: getWidth(6),
        mainAxisSpacing: getHeight(6),
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final imageUrl = _getImageUrl(index);
        final isRealImage = _isRealImage(index);

        return GestureDetector(
          onTap: isRealImage
              ? () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.black,
                    useSafeArea: false,
                    builder: (context) => PhotoViewDialog(
                      imageUrls: diary.imageUrls,
                      currentIndex: index,
                    ),
                  );
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: ColorConfig.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: getWidth(6),
              right: getWidth(6),
              top: getHeight(6),
              bottom: getHeight(18),
            ),
            child: ClipRRect(
              child: AspectRatio(
                aspectRatio: 1,
                child: imageUrl.startsWith('https')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: ColorConfig.gray3.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: ColorConfig.gray3,
                            size: 16,
                          ),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: ColorConfig.gray3.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: ColorConfig.gray3,
                            size: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
