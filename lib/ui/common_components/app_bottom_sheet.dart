import 'package:cake/ui/common_components/app_button.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/common_components/sheet_handle.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 흰 바탕, 위 모서리 28, 핸들 포함 바텀시트의 공통 틀.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    double gap = 20,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: ColorConfig.bgSurface,
      barrierColor: ColorConfig.bgDim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.page,
          right: AppSpacing.page,
          top: 12,
          bottom: 32 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: SheetHandle()),
            SizedBox(height: gap),
            builder(context),
          ],
        ),
      ),
    );
  }
}

enum ConfirmTone { normal, danger }

/// 확인용 바텀시트. Default=일반 확인, Danger=삭제·탈퇴(휴지통 비주얼 + 빨간 버튼).
/// [secondaryLabel]이 null이면 버튼 하나만. true=primary 선택.
class ConfirmSheet {
  ConfirmSheet._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String description,
    required String primaryLabel,
    String? secondaryLabel,
    ConfirmTone tone = ConfirmTone.normal,
    Widget? visual,
    bool isDismissible = true,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      gap: 16,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tone == ConfirmTone.danger)
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: ColorConfig.bgDangerSubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  AppIcons.trash,
                  size: 26,
                  color: ColorConfig.textDanger,
                ),
              ),
            )
          else if (visual != null)
            Center(child: visual),
          if (tone == ConfirmTone.danger || visual != null)
            const SizedBox(height: 16),
          Text(title, style: TextConfig.titleM, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextConfig.bodyM.copyWith(color: ColorConfig.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (secondaryLabel != null) ...[
                Expanded(
                  child: AppButton(
                    label: secondaryLabel,
                    style: AppButtonStyle.neutral,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: AppButton(
                  label: primaryLabel,
                  style: tone == ConfirmTone.danger
                      ? AppButtonStyle.danger
                      : AppButtonStyle.primary,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class ActionSheetItem {
  final String label;
  final bool isDanger;

  const ActionSheetItem(this.label, {this.isDanger = false});
}

/// 더보기 액션 시트. 가운데 정렬 항목 + 닫기 버튼. 선택한 인덱스를 돌려준다.
class ActionSheet {
  ActionSheet._();

  static Future<int?> show(
    BuildContext context, {
    required List<ActionSheetItem> items,
  }) {
    return AppBottomSheet.show<int>(
      context,
      gap: 16,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: ColorConfig.borderSubtle,
              ),
            InkWell(
              onTap: () => Navigator.of(context).pop(i),
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Text(
                    items[i].label,
                    style: TextConfig.bodyL.copyWith(
                      fontWeight: FontWeight.w400,
                      color: items[i].isDanger
                          ? ColorConfig.textDanger
                          : ColorConfig.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          AppButton(
            label: '닫기',
            style: AppButtonStyle.neutral,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
