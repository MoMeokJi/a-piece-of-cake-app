import 'package:cake/config/size_config.dart';
import 'package:cake/domain/model/chat_list_item.dart';
import 'package:cake/presentation/qna_diary_create/components/chat_bubble.dart';
import 'package:cake/ui/style/color_config.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final List<ChatListItem> chatList;
  final ScrollController scrollController;

  const ChatList({
    super.key,
    required this.chatList,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConfig.chatRoomBackground,
      padding: EdgeInsets.symmetric(
        vertical: getHeight(12),
        horizontal: getWidth(20),
      ),
      child: ListView.builder(
        controller: scrollController, // 추가!
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final item = chatList[index];
          return ChatBubble(item: item);
        },
      ),
    );
  }
}
