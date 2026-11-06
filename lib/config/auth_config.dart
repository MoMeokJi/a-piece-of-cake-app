/// 소셜 로그인 클라이언트 ID. 저장소에 적지 않고 빌드 때 dart-define으로 넘긴다.
///
/// - GOOGLE_SERVER_CLIENT_ID: 서버가 idToken의 audience로 검증하는 **웹** 클라이언트 ID.
///   Android·iOS 모두 이 값을 serverClientId로 넘겨야 서버 검증이 통과한다.
/// - GOOGLE_IOS_CLIENT_ID: iOS 클라이언트 ID. GoogleService-Info.plist에 CLIENT_ID가 있으면
///   비워도 되지만, 명시하면 plist와 무관하게 동작한다.
class AuthConfig {
  AuthConfig._();

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  static bool get hasGoogleServerClientId => googleServerClientId.isNotEmpty;
}
