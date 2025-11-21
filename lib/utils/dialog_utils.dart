import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DialogUtils {
  /// 다이얼로그 너비 비율 (화면 너비 85%)
  // static double get _dialogWidthRatio => 0.85;

  /// 앱 업데이트 다이얼로그
  static Future<void> showUpdateDialog({
    required BuildContext context,
    required VoidCallback onUpdatePressed,
    VoidCallback? onLaterPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // 뒤로가기 버튼 비활성화
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('업데이트 알림'),
          titleTextStyle: TextStyle(
            fontSize: getWidth(20),
            color: ColorConfig.black,
          ),
          content: Text('새로운 앱 버전이 출시되었습니다.\n지금 업데이트 하시겠습니까?'),
          contentTextStyle: TextStyle(
            fontSize: getWidth(16),
            // fontWeight: FontWeight.w600,
            color: ColorConfig.black,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: getHeight(20), // 위쪽 패딩 증가
            horizontal: getWidth(24),
          ),
          actions: [
            Row(
              children: [
                if (onLaterPressed != null)
                  Expanded(
                    child: SizedBox(
                      height: getWidth(44),
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          onLaterPressed();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: ColorConfig.white,
                          foregroundColor: ColorConfig.primary,
                          side: BorderSide(
                            color: ColorConfig.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          '나중에',
                          style: TextStyle(
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onLaterPressed != null) SizedBox(width: getWidth(8)),
                Expanded(
                  child: SizedBox(
                    height: getWidth(44),
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        onUpdatePressed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConfig.primary,
                        foregroundColor: ColorConfig.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '업데이트',
                        style: TextStyle(
                          fontSize: getWidth(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
