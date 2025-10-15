import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class DiaryTextField extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isKeyboardVisible;

  const DiaryTextField({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isKeyboardVisible,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: isKeyboardVisible ? 13 : 23,
      maxLines: isKeyboardVisible ? 13 : 23,
      maxLength: 1500,
      controller: textController,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        color: ColorConfig.diaryTextColor,
        fontSize: getWidth(14),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorConfig.white,
        hintText: '하고 싶은 말을 자유롭게 적어주세요',
        hintStyle: TextStyle(color: ColorConfig.gray3, fontSize: getWidth(14)),
        helperStyle: TextStyle(
          color: ColorConfig.gray3,
          fontSize: getWidth(14),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(15),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorConfig.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorConfig.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorConfig.primary),
        ),
      ),
    );
  }
}
