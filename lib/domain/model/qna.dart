class Qna {
  final int id;
  final String question;
  final String answer;

  /// 건너뛴 문항. 서버에 보내지 않는다.
  final bool skipped;

  const Qna({
    required this.id,
    required this.question,
    required this.answer,
    this.skipped = false,
  });

  bool get isAnswered => !skipped && answer.trim().isNotEmpty;

  Qna copyWith({String? answer, bool? skipped}) => Qna(
    id: id,
    question: question,
    answer: answer ?? this.answer,
    skipped: skipped ?? this.skipped,
  );
}
