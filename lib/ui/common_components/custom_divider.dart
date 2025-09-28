import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double? thickness;
  final double? width;
  final Color? color;
  const CustomDivider({super.key, this.thickness, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness ?? getHeight(0.5),
      width: width,
      color: color ?? ColorConfig.border,
    );
  }
}
