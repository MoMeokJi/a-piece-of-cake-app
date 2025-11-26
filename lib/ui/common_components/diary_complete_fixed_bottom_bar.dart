import 'package:cake/config/service_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiaryCompleteFixedBottomBar extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onCompleted;
  final int currentImageCount;
  const DiaryCompleteFixedBottomBar({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onCompleted,
    required this.currentImageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(56),
      decoration: BoxDecoration(
        color: ColorConfig.background,
        border: Border(top: BorderSide(color: ColorConfig.gray4, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: getWidth(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.camera, size: getHeight(24)),
            onPressed: onCameraTap,
          ),
          IconButton(
            icon: Icon(CupertinoIcons.photo, size: getHeight(24)),
            onPressed: onGalleryTap,
          ),
          SizedBox(width: getWidth(10)),
          Text(
            '$currentImageCount/${ServiceConfig.maxImageCount}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: getWidth(12), color: ColorConfig.black),
          ),
          Spacer(),
          TextButton.icon(
            onPressed: onCompleted,
            label: Text('일기 완성하기'),
            icon: Icon(Icons.check_rounded),
            iconAlignment: IconAlignment.end,
            style: TextButton.styleFrom(
              foregroundColor: ColorConfig.primary,
              textStyle: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
