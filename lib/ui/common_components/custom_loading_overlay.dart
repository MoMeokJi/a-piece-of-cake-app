import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingOverlay extends StatelessWidget {
  final String message;

  const CustomLoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitPumpingHeart(color: ColorConfig.secondary, size: 35.0),
            SizedBox(height: getHeight(16)),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.bold,
                color: ColorConfig.white,
                letterSpacing: 2.0,
              ),
              child: AnimatedTextKit(
                animatedTexts: [WavyAnimatedText(message)],
                isRepeatingAnimation: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
