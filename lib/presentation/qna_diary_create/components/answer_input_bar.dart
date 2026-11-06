import 'package:cake/config/service_config.dart';
import 'package:cake/ui/common_components/app_icon.dart';
import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 문답 입력 바. 둥근 입력창(카운터 포함) + 전송 버튼.
class AnswerInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool enabled;

  const AnswerInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    this.enabled = true,
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
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final hasText = value.text.trim().isNotEmpty;
          final canSend = enabled && hasText;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConfig.bgSurface,
                    border: Border.all(
                      color: focusNode.hasFocus
                          ? ColorConfig.borderFocus
                          : ColorConfig.borderDefault,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        enabled: enabled,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: ServiceConfig.maxChatLength,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: TextConfig.bodyM,
                        cursorColor: ColorConfig.brandBlue,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          counterText: '',
                          hintText: '답변을 입력해주세요',
                          hintStyle: TextConfig.bodyM.copyWith(
                            color: ColorConfig.textTertiary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      Text(
                        '${value.text.characters.length}/${ServiceConfig.maxChatLength}',
                        style: TextConfig.numberS.copyWith(
                          color: ColorConfig.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: '보내기',
                child: GestureDetector(
                  onTap: canSend ? onSend : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canSend
                          ? ColorConfig.brandBlue
                          : ColorConfig.actionDisabled,
                    ),
                    alignment: Alignment.center,
                    child: AppIcon(
                      AppIcons.arrowUp,
                      size: 20,
                      color: canSend
                          ? ColorConfig.textOnDark
                          : ColorConfig.textDisabled,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
