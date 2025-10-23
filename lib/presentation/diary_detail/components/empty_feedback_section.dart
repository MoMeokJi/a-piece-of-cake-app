import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class EmptyFeedbackSection extends StatelessWidget {
  const EmptyFeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorConfig.primary.withValues(alpha: 0.2),
              ColorConfig.secondary.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(16),
            vertical: getHeight(15),
          ),
          child: Row(
            children: [
              Transform.flip(
                flipX: true,
                child: Image.asset(
                  'assets/images/blueberry_plate.png',
                  width: getWidth(70),
                  height: getHeight(70),
                ),
              ),
              SizedBox(width: getWidth(12)),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'NanumSquareRound',
                    fontSize: getWidth(18),
                    color: ColorConfig.gray1,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: '곧 '),
                    TextSpan(
                      text: '달콤한 한마디',
                      style: TextStyle(color: ColorConfig.primary),
                    ),
                    TextSpan(text: '가 도착해요!'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
