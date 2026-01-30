import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

class ReadModeTextBox extends StatelessWidget {
  final String content;
  final VoidCallback onEdit;
  const ReadModeTextBox({
    super.key,
    required this.content,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorConfig.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ColorConfig.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(15),
              vertical: getHeight(15),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: TextConfig.diaryGaramFontSize,
                color: ColorConfig.diaryGaramTextColor,
                fontFamily: 'NanumGaram',
                height: 1.5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onEdit,
              label: Text('수정하기'),
              icon: Icon(Icons.edit),
              iconAlignment: IconAlignment.end,
              style: TextButton.styleFrom(
                foregroundColor: ColorConfig.secondary,
                textStyle: TextStyle(
                  fontSize: getWidth(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
