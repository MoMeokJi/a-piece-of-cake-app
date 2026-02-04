import 'package:cake/config/service_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

class DiaryEditTextField extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isKeyboardVisible;
  final String? hintText;

  const DiaryEditTextField({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isKeyboardVisible,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: isKeyboardVisible ? 16 : 25,
      maxLines: isKeyboardVisible ? 16 : 25,
      maxLength: ServiceConfig.maxDiaryLength,
      controller: textController,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
        color: ColorConfig.diaryTextColor,
        fontSize: TextConfig.diaryDefaultFontSize,
        fontFamily: 'Pretendard',
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorConfig.white,
        hintText: hintText,
        hintStyle: TextStyle(color: ColorConfig.gray3, fontSize: getWidth(14)),
        helperStyle: TextStyle(
          color: ColorConfig.gray3,
          fontSize: TextConfig.diaryDefaultFontSize,
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
