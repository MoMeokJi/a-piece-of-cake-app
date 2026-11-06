import 'package:cake/config/service_config.dart';
import 'package:cake/ui/style/app_dimens.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 흰 카드 안의 본문 편집기. 아래 오른쪽에 글자 수. [focused]면 블루 테두리 2.
class DiaryEditorCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final bool showFocusBorder;

  const DiaryEditorCard({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.showFocusBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final focused = showFocusBorder && focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: ColorConfig.bgSurface,
            borderRadius: AppRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.card,
            border: focused
                ? Border.all(color: ColorConfig.borderFocus, width: 2)
                : null,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  maxLength: ServiceConfig.maxDiaryLength,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextConfig.bodyMLong,
                  cursorColor: ColorConfig.brandBlue,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: hintText,
                    hintStyle: TextConfig.bodyMLong.copyWith(
                      color: ColorConfig.textTertiary,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.text.characters.length}/${ServiceConfig.maxDiaryLength}',
                  style: TextConfig.numberS.copyWith(
                    color: ColorConfig.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
