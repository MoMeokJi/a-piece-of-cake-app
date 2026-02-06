import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class MenuListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const MenuListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: getHeight(14),
          color: color ?? ColorConfig.black,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color ?? ColorConfig.gray2),
      contentPadding: EdgeInsets.symmetric(horizontal: getWidth(25)),
      onTap: onTap,
      dense: true,
    );
  }
}
