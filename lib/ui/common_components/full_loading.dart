import 'dart:async';

import 'package:cake/ui/style/app_assets.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 전체 화면 로딩. 문구는 2~3초마다 순환하고 점 표시가 현재 문구를 가리킨다.
/// 문답 생성과 일기 확정에 공통으로 쓴다.
class FullLoading extends StatefulWidget {
  final List<String> messages;
  final String subMessage;

  const FullLoading({
    super.key,
    required this.messages,
    this.subMessage = '잠시만 기다려 주세요',
  });

  static const List<String> qnaMessages = [
    '답변을 모아 일기를 굽고 있어요',
    '오늘의 이야기를 정리하고 있어요',
    '거의 다 구워졌어요',
  ];

  static const List<String> saveMessages = [
    '오늘의 컬러를 고르고 있어요',
    '어울리는 음악을 찾고 있어요',
    '예쁘게 포장 중이에요',
  ];

  @override
  State<FullLoading> createState() => _FullLoadingState();
}

class _FullLoadingState extends State<FullLoading>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  Timer? _timer;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.messages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.pageTop),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.96, end: 1.04).animate(
                      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                    ),
                    child: SvgPicture.asset(
                      AppImages.loadingHalo,
                      width: 180,
                      height: 180,
                    ),
                  ),
                  SvgPicture.asset(
                    AppImages.loadingRing,
                    width: 140,
                    height: 140,
                  ),
                  Image.asset(
                    AppImages.cakePlateStrawberry,
                    width: 92,
                    height: 100,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                widget.messages[_index],
                key: ValueKey(_index),
                style: TextConfig.titleS,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subMessage,
              style: TextConfig.bodyS.copyWith(
                color: ColorConfig.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.messages.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? ColorConfig.brandBlue
                          : ColorConfig.actionPrimary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
