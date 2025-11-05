import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatListItem item;
  const ChatBubble({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 화면 너비 대비 말풍선 최대 너비 설정
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.72;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(8)),
      child: Row(
        mainAxisAlignment: item.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!item.isUser) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/profile_image.png'),
              ),
            ),
          ],

          // 말풍선 컨테이너
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(12),
                vertical: getHeight(10),
              ),
              decoration: BoxDecoration(
                color: item.isUser ? ColorConfig.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(item.isUser ? 12 : 2),
                  bottomRight: Radius.circular(item.isUser ? 2 : 12),
                ),
              ),
              child: _buildContentWidget(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(ChatListItem item) {
    final textStyle = TextStyle(
      color: item.isUser ? Colors.white : ColorConfig.gray1,
      fontSize: getWidth(14),
      height: 1.3,
    );

    // 유저 메시지는 그냥 텍스트
    if (item.isUser) {
      return Text(item.content, style: textStyle);
    }

    // 봇 메시지만 타이핑 애니메이션
    return AnimatedTextKit(
      key: ValueKey(item.content), // content 바뀔 때마다 새로 생성
      isRepeatingAnimation: false,
      totalRepeatCount: 1,
      animatedTexts: [
        TyperAnimatedText(
          item.content,
          textStyle: textStyle,
          speed: Duration(milliseconds: 50),
        ),
      ],
    );
  }
}
