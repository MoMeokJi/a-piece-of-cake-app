import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitPouringHourGlass(
              color: ColorConfig.secondary,
              size: 35.0,
            ),
            SizedBox(height: getHeight(15)),
            DefaultTextStyle(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getWidth(18),
                color: ColorConfig.white,
                letterSpacing: 2.0,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    '일기를 생성하는 중입니다...',
                    speed: Duration(milliseconds: 150),
                  ),
                ],
                isRepeatingAnimation: true,
              ),
            ),
            SizedBox(height: getHeight(50)),
          ],
        ),
      ),
    );
  }
}
