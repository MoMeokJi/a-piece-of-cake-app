import 'package:cake/ui/common_components/cake_avatar.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:cake/ui/style/text_config.dart';
import 'package:flutter/material.dart';

/// 문답 말풍선. 봇은 왼쪽(아바타 + 흰 말풍선), 나는 오른쪽(연파랑).
/// 메시지는 최대 너비 230에서 줄바꿈.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
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
        child: Text(message, style: TextConfig.bodyMChat),
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
