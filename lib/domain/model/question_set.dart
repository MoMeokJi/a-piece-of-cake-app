import 'package:cake/domain/model/qna.dart';

/// 문답 한 회차의 질문 묶음. 작성 화면 진입 때 한 번만 받는다.
class QuestionSet {
  /// 보여줄 질문. 앞쪽은 필수([Qna.required]), 뒤쪽은 선택.
  final List<Qna> questions;

  /// 선택 질문을 건너뛸 때 그 자리에 대신 넣을 여분 질문. 비어 있을 수 있다.
  final List<String> optionalSpares;

  const QuestionSet({required this.questions, this.optionalSpares = const []});

  bool get isEmpty => questions.isEmpty;
}
