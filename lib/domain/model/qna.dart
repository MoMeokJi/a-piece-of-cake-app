class Qna {
  final int id;
  final String question;
  final String answer;

  /// 필수 문항. 건너뛰기 버튼을 보여주지 않는다.
  final bool required;

  const Qna({
    required this.id,
    required this.question,
    required this.answer,
    this.required = false,
  });

  bool get isAnswered => answer.trim().isNotEmpty;

  Qna copyWith({String? question, String? answer}) => Qna(
    id: id,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    required: required,
  );
}
