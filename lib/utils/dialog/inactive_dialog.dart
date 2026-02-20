import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InactivityDialog extends StatelessWidget {
  final VoidCallback onConfirmed;

  const InactivityDialog({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('오랜만이에요!',),
        titleTextStyle: TextStyle(fontSize: getWidth(24), color: ColorConfig.black,fontWeight: FontWeight.bold),
        content: Text('서비스 이용 정책에 따라 장기간 미접속 회원의 데이터가 삭제됐어요🥲\n\n오늘부터 새로운 기록을 시작해보세요!'),
        contentTextStyle: TextStyle(fontSize: getWidth(18), color: ColorConfig.gray1),
        contentPadding: EdgeInsets.symmetric(vertical: getHeight(30), horizontal: getWidth(24)),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: getWidth(50),
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      onConfirmed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConfig.primary,
                      foregroundColor: ColorConfig.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 0,
                    ),
                    child: Text('확인', style: TextStyle(fontSize: getWidth(16), fontWeight: FontWeight.w500)),
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