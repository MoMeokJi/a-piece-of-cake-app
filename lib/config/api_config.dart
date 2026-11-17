class ApiConfig {
  ApiConfig._();

  /// 빌드 때 `--dart-define=API_BASE_URL=...`로 바꾼다 (테스트 서버 등).
  /// 배포 스크립트는 `--dart-define-from-file`로 KEYS_DIR의 파일을 넘긴다.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://piece-of-cake.click',
  );

  /// 약관·방침 페이지. 새 서버가 운영에 배포된 뒤에 열린다 (그 전에는 401).
  /// 예전 S3 PDF는 익명 앱 시절 내용이라 더 쓰지 않는다.
  static const String serviceTermUrl = 'https://piece-of-cake.click/terms';
  static const String privacyPolicyUrl = 'https://piece-of-cake.click/privacy';
}
