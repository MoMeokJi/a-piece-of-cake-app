import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UpdateDialog extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final VoidCallback? onLaterPressed;

  const UpdateDialog({
    super.key,
    required this.onUpdatePressed,
    this.onLaterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('업데이트 알림'),
        titleTextStyle: TextStyle(fontSize: getWidth(24), color: ColorConfig.black,fontWeight: FontWeight.bold,),
        content: Text('새로운 앱 버전이 출시되었습니다 🙌\n\n지금 바로 업데이트 할까요?'),
        contentTextStyle: TextStyle(fontSize: getWidth(18), color: ColorConfig.gray1),
        contentPadding: EdgeInsets.symmetric(vertical: getHeight(30), horizontal: getWidth(24)),
        actions: [
          Row(
            children: [
              if (onLaterPressed != null) ...[
                Expanded(
                  child: SizedBox(
                    height: getWidth(50),
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                        onLaterPressed!();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: ColorConfig.white,
                        foregroundColor: ColorConfig.primary,
                        side: BorderSide(color: ColorConfig.primary, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                      child: Text('나중에', style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                SizedBox(width: getWidth(8)),
              ],
              Expanded(
                child: SizedBox(
                  height: getWidth(50),
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      onUpdatePressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConfig.primary,
                      foregroundColor: ColorConfig.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 0,
                    ),
                    child: Text('업데이트', style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}