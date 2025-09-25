import 'package:cake/config/color_config.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/presentation/main/components/bottom_navi.dart';
import 'package:cake/presentation/main/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    return Scaffold(
      backgroundColor: ColorConfig.background,
      body: Column(
        children: [
          // 상단 고정 배너
          Container(
            width: double.infinity,
            height: getHeight(230),
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
                  offset: const Offset(0, 1), // 위쪽으로 그림자 효과
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
                      fontSize: getWidth(18), // 사이즈는 조정하세요
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
          ),
          // 하단 탭 컨텐츠
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: BottomNavi(
        currentIndex: navigationShell.currentIndex,
        changeTap: (index) => navigationShell.goBranch(index),
      ),
      floatingActionButton: RawMaterialButton(
        constraints: BoxConstraints.tightFor(
          width: getWidth(80),
          height: getHeight(80),
        ),
        shape: const CircleBorder(),
        elevation: 0,
        fillColor: ColorConfig.primary,
        onPressed: () async {},
        child: Icon(
          Icons.create_outlined,
          color: ColorConfig.white,
          size: getHeight(40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
