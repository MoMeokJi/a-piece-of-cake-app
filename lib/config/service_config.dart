class ServiceConfig {
  ServiceConfig._();

  // 이미지 최대 첨부 개수
  static const int maxImageCount = 4;

  // 일기 최소 글자수
  static const int minDiaryLength = 30;

  // 일기 최대 글자수
  static const int maxDiaryLength = 1500;

  // 채팅 최대 글자수
  static const int maxChatLenght = 100;

  // 하루 최대 작성 가능 일기 수 
  static const int maxDiaryCount = 3;

  // 비활성 유저 판단 기준 (서버 180일보다 이틀 앞서 처리)
  static const int inactivityThresholdDays = 178;
}
