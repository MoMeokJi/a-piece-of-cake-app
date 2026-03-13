import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DiaryCompleteLoadingOverlay extends StatelessWidget {
   final String? message;

 const  DiaryCompleteLoadingOverlay({super.key,  this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinKitPumpingHeart(
                color: ColorConfig.secondary,
                size: 35.0,
              ),
              SizedBox(height: getHeight(20)),
              DefaultTextStyle(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: getWidth(20),
                  color: ColorConfig.white,
                  letterSpacing: 2.0,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [WavyAnimatedText(message??'오늘의 조각을 저장하고 있어요')],
                  isRepeatingAnimation: true,
                ),
              ),
              SizedBox(height: getHeight(35)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(32)),
                child: Text(
                  '화면을 벗어나면 일기가\n저장되지 않을 수 있습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: ColorConfig.white.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
