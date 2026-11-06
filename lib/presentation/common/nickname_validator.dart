import 'package:cake/config/service_config.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

enum NicknameValidation {
  valid,
  empty,
  tooLong,
  tooShort,
  invalidChars;

  bool get isValid => this == NicknameValidation.valid;

  /// 피그마 Field Message 문구. 오류는 두 가지만: 글자 수, 형식.
  String? get message => switch (this) {
    NicknameValidation.valid => '사용할 수 있는 닉네임이에요',
    NicknameValidation.empty => null,
    NicknameValidation.tooLong ||
    NicknameValidation.tooShort => '2~10자로 입력해 주세요',
    NicknameValidation.invalidChars => '한글, 영문, 숫자만 쓸 수 있어요',
  };
}

NicknameValidation validateNickname(String value) {
  final text = value.trim();
  if (text.isEmpty) return NicknameValidation.empty;
  if (!ServiceConfig.nicknameAllowedChars.hasMatch(text)) {
    return NicknameValidation.invalidChars;
  }
  final length = text.characters.length;
  if (length > ServiceConfig.nicknameMaxLength) return NicknameValidation.tooLong;
  if (length < ServiceConfig.nicknameMinLength) {
    return NicknameValidation.tooShort;
  }
  return NicknameValidation.valid;
}
