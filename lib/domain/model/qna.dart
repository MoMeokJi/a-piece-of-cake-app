// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';
part 'qna.freezed.dart';

@freezed
class Qna with _$Qna {
  final int id;
  final String question;
  final String answer;

  const Qna({required this.id, required this.question, required this.answer});
}
