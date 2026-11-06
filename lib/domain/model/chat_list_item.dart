class ChatListItem {
  final bool isUser;
  final String content;

  /// user 버블에만 쓴다 (편집 연결용 질문 인덱스)
  final int? qnaIndex;

  const ChatListItem({
    required this.isUser,
    required this.content,
    this.qnaIndex,
  });

  factory ChatListItem.bot(String content) =>
      ChatListItem(isUser: false, content: content);

  factory ChatListItem.user(String content, {int? qnaIndex}) =>
      ChatListItem(isUser: true, content: content, qnaIndex: qnaIndex);
}
