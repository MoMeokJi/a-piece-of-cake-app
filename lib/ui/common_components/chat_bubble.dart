import 'dart:async';

import 'package:cake/ui/common_components/cake_avatar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 문답 말풍선. 봇은 왼쪽(아바타 + 흰 말풍선), 나는 오른쪽(연파랑).
/// 메시지는 최대 너비 230에서 줄바꿈.
/// [animated]면 글자가 한 자씩 타자처럼 나타난다 (봇 질문용). 말풍선 크기는 처음부터
/// 전체 문장 기준으로 잡혀서 타이핑 중에 흔들리지 않는다.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool animated;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.animated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 262),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? ColorConfig.bgTintBlue : ColorConfig.bgSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 18 : 4),
            topRight: Radius.circular(isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          boxShadow: isUser ? null : AppShadows.bubble,
        ),
        child: animated
            ? _TypewriterText(message, style: TextConfig.bodyMChat)
            : Text(message, style: TextConfig.bodyMChat),
      ),
    );

    if (isUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Flexible(child: bubble)],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CakeAvatar(),
        const SizedBox(width: 8),
        Flexible(child: bubble),
      ],
    );
  }
}

/// 글자를 한 자씩 드러내는 텍스트. 아직 안 나온 글자는 투명하게 그려서 줄바꿈과
/// 크기는 완성된 문장과 같다. 문장이 바뀌면 처음부터 다시 친다.
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText(this.text, {required this.style});

  static const Duration charInterval = Duration(milliseconds: 50);

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  Timer? _timer;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _start();
  }

  void _start() {
    _timer?.cancel();
    _shown = 0;
    final runes = widget.text.runes.length;
    _timer = Timer.periodic(_TypewriterText.charInterval, (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _shown++);
      if (_shown >= runes) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final runes = widget.text.runes.toList();
    final cut = _shown.clamp(0, runes.length);
    final visible = String.fromCharCodes(runes.sublist(0, cut));
    final hidden = String.fromCharCodes(runes.sublist(cut));
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: visible),
          TextSpan(
            text: hidden,
            style: const TextStyle(color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
