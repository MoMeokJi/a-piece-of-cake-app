class ChatListItem {
  final bool isUser;
  final String content;
  final int? qnaIndex; // user 버블에만 사용 (편집 연결용)

  const ChatListItem({
    required this.isUser,
    required this.content,
    this.qnaIndex,
  });

  factory ChatListItem.bot(String content) =>
      ChatListItem(isUser: false, content: content);

  factory ChatListItem.user(String content, {int? qnaIndex}) =>
      ChatListItem(isUser: true, content: content, qnaIndex: qnaIndex);

  ChatListItem copyWith({bool? isUser, String? content, int? qnaIndex}) =>
      ChatListItem(
        isUser: isUser ?? this.isUser,
        content: content ?? this.content,
        qnaIndex: qnaIndex ?? this.qnaIndex,
      );
}
