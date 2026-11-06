import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/model/auth_session.dart';
import 'package:cake/domain/repository/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  bool hasSessionValue = false;
  AuthSession? sessionToReturn;
  Object? signInError;
  int registerFcmCallCount = 0;
  int logoutCallCount = 0;
  int clearSessionCallCount = 0;
  SocialProvider? lastProvider;

  @override
  Future<AuthSession> signIn(SocialProvider provider) async {
    lastProvider = provider;
    final error = signInError;
    if (error != null) throw error;
    hasSessionValue = true;
    return sessionToReturn ??
        const AuthSession(accessToken: 'a', refreshToken: 'r');
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
    hasSessionValue = false;
  }

  @override
  Future<void> clearSession() async {
    clearSessionCallCount++;
    hasSessionValue = false;
  }

  @override
  Future<bool> hasSession() async => hasSessionValue;

  @override
  Future<void> registerFcmToken() async => registerFcmCallCount++;
}
