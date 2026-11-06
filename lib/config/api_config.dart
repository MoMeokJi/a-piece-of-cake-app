class ApiConfig {
  ApiConfig._();

  /// 빌드 때 `--dart-define=API_BASE_URL=...`로 바꾼다 (테스트 서버 등).
  /// 배포 스크립트는 `--dart-define-from-file`로 KEYS_DIR의 파일을 넘긴다.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://piece-of-cake.click:8080',
  );

  static const String serviceTermUrl =
      'https://piece-of-cake-image.s3.ap-northeast-2.amazonaws.com/%EC%A1%B0%EA%B0%81%EC%BC%80%EC%9D%B4%ED%81%AC_%EC%84%9C%EB%B9%84%EC%8A%A4_%EC%9D%B4%EC%9A%A9%EC%95%BD%EA%B4%80.pdf';
  static const String privacyPolicyUrl =
      'https://piece-of-cake-image.s3.ap-northeast-2.amazonaws.com/%EC%A1%B0%EA%B0%81%EC%BC%80%EC%9D%B4%ED%81%AC_%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4_%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.pdf';
}
