import 'package:cake/config/service_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class BottomFixedInputSection extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onCompleted;
  final bool isKeyboardVisible;

  const BottomFixedInputSection({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onCompleted,
    required this.isKeyboardVisible,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = isKeyboardVisible ? getHeight(10) : getHeight(1);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ColorConfig.border, width: 0.5)),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          left: getWidth(16),
          right: getWidth(16),
          bottom: getHeight(bottomPadding),
          top: getHeight(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextFormField 영역
            Expanded(
              child: TextFormField(
                controller: textController,
                focusNode: focusNode,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                maxLength: ServiceConfig.maxChatLenght,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onCompleted();
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getWidth(14),
                  fontFamily: 'Pretendard',
                ),
                decoration: InputDecoration(
                  hintText: '답변을 입력해주세요',
                  hintStyle: TextStyle(
                    color: ColorConfig.gray3,
                    fontSize: getWidth(14),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: getWidth(16),
                    vertical: getHeight(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConfig.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConfig.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConfig.primary),
                  ),
                  filled: true,
                  fillColor: ColorConfig.white,
                ),
              ),
            ),

            SizedBox(width: getWidth(8)),

            // 전송 버튼
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: textController,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? onCompleted : null,
                  child: Container(
                    width: getWidth(48),
                    height: getWidth(48),
                    decoration: BoxDecoration(
                      color: hasText ? ColorConfig.primary : ColorConfig.gray4,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: hasText ? Colors.white : ColorConfig.gray2,
                      // size: getWidth(28),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
