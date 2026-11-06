import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/model/social_credential.dart';

/// 소셜 SDK 호출. 취소는 [SocialSignInCancelledException], 그 밖의 실패는
/// [SocialSignInFailedException]으로 올린다.
abstract interface class SocialSignInService {
  Future<SocialCredential> signIn(SocialProvider provider);

  /// SDK 쪽 세션을 끊는다. 실패는 삼킨다.
  Future<void> signOut(SocialProvider provider);
}
