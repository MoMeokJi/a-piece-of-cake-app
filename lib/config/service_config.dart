class ServiceConfig {
  ServiceConfig._();

  /// 이미지 최대 첨부 개수
  static const int maxImageCount = 4;

  /// 일기 최소 글자수
  static const int minDiaryLength = 30;

  /// 일기 최대 글자수
  static const int maxDiaryLength = 1500;

  /// 문답 답변 최대 글자수
  static const int maxChatLength = 100;

  /// 하루 최대 작성 가능 일기 수. 서버 stats의 dailyLimit을 못 받았을 때만 쓴다.
  static const int maxDiaryCount = 3;

  /// 문답 질문 5개 중 앞에서부터 필수인 개수 (서버 규칙: 1·2번 필수, 3~5번 선택)
  static const int qnaRequiredCount = 2;

  /// 목록 한 페이지 크기
  static const int diaryPageSize = 10;

  /// 닉네임 규칙: 완성형 한글·영문·숫자 2~10자 (서버와 같은 정규식)
  static const int nicknameMinLength = 2;
  static const int nicknameMaxLength = 10;
  static final RegExp nicknamePattern = RegExp(r'^[가-힣A-Za-z0-9]{2,10}$');
  static final RegExp nicknameAllowedChars = RegExp(r'^[가-힣A-Za-z0-9]*$');
}
