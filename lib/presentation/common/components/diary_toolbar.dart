import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 자유 일기 툴바: 카메라 · 앨범 · "사진 n/4" · 완성하기.
class DiaryToolbar extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final int imageCount;
  final int imageMax;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool actionEnabled;
  final bool actionLoading;

  const DiaryToolbar({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.imageCount,
    required this.imageMax,
    required this.actionLabel,
    required this.onAction,
    this.actionEnabled = true,
    this.actionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: ColorConfig.bgSurface,
        border: Border(top: BorderSide(color: ColorConfig.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset > 0 ? bottomInset : 12),
      child: Row(
        children: [
          AppIconButton(
            icon: AppIcons.camera,
            semanticLabel: '카메라',
            onPressed: onCamera,
          ),
          AppIconButton(
            icon: AppIcons.image,
            semanticLabel: '앨범',
            onPressed: onGallery,
          ),
          const SizedBox(width: 4),
          Text(
            '사진 $imageCount/$imageMax',
            style: TextConfig.label.copyWith(color: ColorConfig.textSecondary),
          ),
          const Spacer(),
          AppButton(
            label: actionLabel,
            width: 104,
            height: 44,
            enabled: actionEnabled,
            isLoading: actionLoading,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
