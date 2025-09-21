import 'package:cake/config/color_config.dart';
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
            height: 200, // 배너 높이 조정 가능
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/main_banner.png'),
                fit: BoxFit.cover,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConfig.primary,
        shape: const CircleBorder(),
        onPressed: () async {},
        child: const Icon(Icons.create_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
