import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class EditModeBottomFixedBar extends StatelessWidget {
  final VoidCallback onCompleted;
  const EditModeBottomFixedBar({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(56),
      decoration: BoxDecoration(
        color: ColorConfig.background,
        border: Border(top: BorderSide(color: ColorConfig.gray4, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(horizontal: getWidth(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: onCompleted,
            label: Text('수정 완료'),
            icon: Icon(Icons.check_rounded),
            iconAlignment: IconAlignment.end,
            style: TextButton.styleFrom(
              foregroundColor: ColorConfig.secondary,
              textStyle: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
