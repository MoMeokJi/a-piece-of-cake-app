import 'package:cake/config/size_config.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class MainBanner extends StatelessWidget {
  const MainBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: getHeight(210),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main_banner.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: getHeight(35)),
            Text(
              '오늘은 어떤 하루였나요?',
              style: TextStyle(
                fontSize: getWidth(18),
                color: ColorConfig.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'piece of cake',
              style: TextStyle(
                fontFamily: 'DCC',
                fontSize: getWidth(40),
                color: ColorConfig.white,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
