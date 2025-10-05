import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class BasicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double elevation;

  const BasicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? getHeight(56),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (backgroundColor ?? ColorConfig.primary)
              : ColorConfig.disabled,
          disabledBackgroundColor: ColorConfig.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          elevation: elevation,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? getWidth(16),
            fontWeight: FontWeight.w500,
            color: textColor ?? ColorConfig.white,
          ),
        ),
      ),
    );
  }
}
