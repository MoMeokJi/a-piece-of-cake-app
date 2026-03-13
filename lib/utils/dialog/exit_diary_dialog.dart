import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExitDiaryDialog extends StatelessWidget {
  const ExitDiaryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('작성중인 일기가 있어요!'),
          titleTextStyle: TextStyle(fontSize: getWidth(24), color: ColorConfig.black,),
      content: const Text('일기 작성중에 화면을 나가면 내용이 저장되지 않아요.'),
             contentTextStyle: TextStyle(fontSize: getWidth(18), color: ColorConfig.gray1),
      contentPadding: EdgeInsets.symmetric(
        vertical: getHeight(20),
        horizontal: getWidth(24),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: getWidth(50),
                child: ElevatedButton(
                  onPressed: () => context.pop(false),
                   style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConfig.primary,
                      foregroundColor: ColorConfig.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 0,
                    ),
               
                  child: Text(
                    '계속 작성',
                 style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.w500)
                  ),
                ),
              ),
            ),
            SizedBox(width: getWidth(8)),
            Expanded(
              child: SizedBox(
                height: getWidth(50),
                child: OutlinedButton(
                  onPressed: () => context.pop(true),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: ColorConfig.white,
                        foregroundColor: ColorConfig.primary,
                        side: BorderSide(color: ColorConfig.primary, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                  child: Text(
                    '나가기',
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}