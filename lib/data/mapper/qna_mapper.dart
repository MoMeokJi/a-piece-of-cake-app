import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/model/qna.dart';

extension QnaMapper on Qna {
  QnaRequestDto toDto() {
    return QnaRequestDto(question: question, answer: answer);
  }
}
