// ignore_for_file: annotate_overrides

import 'package:freezed_annotation/freezed_annotation.dart';
part 'qna.freezed.dart';

@freezed
class Qna with _$Qna {
  final String question;
  final String answer;

  const Qna({required this.question, required this.answer});

  factory Qna.empty() => Qna(question: '', answer: '');
}
