// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';
part 'chat_list_item.freezed.dart';

@freezed
class ChatListItem with _$ChatListItem {
  final bool isUser;
  final String content;

  const ChatListItem({required this.isUser, required this.content});

  factory ChatListItem.bot(String content) =>
      ChatListItem(isUser: false, content: content);

  factory ChatListItem.user(String content) =>
      ChatListItem(isUser: true, content: content);
}
