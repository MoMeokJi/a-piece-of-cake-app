import 'package:cake/domain/enum/social_provider.dart';
import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/domain/model/auth_session.dart';
import 'package:cake/domain/service/analytics_service.dart';
import 'package:cake/presentation/common/app_error_messages.dart';
import 'package:cake/presentation/login/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_app_prefs_repository.dart';
import '../../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository authRepo;
  late FakeAppPrefsRepository prefsRepo;

  setUp(() {
    authRepo = FakeAuthRepository();
    prefsRepo = FakeAppPrefsRepository();
  });

  LoginViewModel build({bool isAndroid = false}) => LoginViewModel(
    authRepo: authRepo,
    prefsRepo: prefsRepo,
    analytics: const NoopAnalyticsService(),
    isAndroid: isAndroid,
  );

  test('Android는 Google 버튼만, iOS는 Apple·Google 순서', () {
    expect(build(isAndroid: true).providers, [SocialProvider.google]);
    expect(build().providers, [SocialProvider.apple, SocialProvider.google]);
  });

  test('약관 동의 시 알림 선택값을 보관한다', () async {
    final vm = build();
    await vm.agreeTerms(notificationOptIn: true);

    expect(vm.termsAgreed, isTrue);
    expect(prefsRepo.pendingNotificationOptIn, isTrue);
  });

  test('기존 회원이면 FCM 토큰을 등록하고 홈으로 보낸다', () async {
    authRepo.sessionToReturn = const AuthSession(
      accessToken: 'a',
      refreshToken: 'r',
      isNewMember: false,
    );
    final vm = build();

    await vm.signIn(SocialProvider.google);

    expect(vm.outcome, isA<LoginToHome>());
    expect(authRepo.registerFcmCallCount, 1);
    expect(vm.isLoading, isFalse);
  });

  test('신규 회원이면 SDK 이름을 들고 닉네임 설정으로 보낸다', () async {
    authRepo.sessionToReturn = const AuthSession(
      accessToken: 'a',
      refreshToken: 'r',
      isNewMember: true,
      nickname: '서윤',
    );
    final vm = build();

    await vm.signIn(SocialProvider.apple);

    final outcome = vm.outcome;
    expect(outcome, isA<LoginToNicknameSetup>());
    expect((outcome as LoginToNicknameSetup).initialNickname, '서윤');
    expect(authRepo.registerFcmCallCount, 0, reason: '닉네임 설정 뒤에 등록한다');
  });

  test('취소하면 안내 토스트, 재시도 없음', () async {
    authRepo.signInError = const SocialSignInCancelledException();
    final vm = build();

    await vm.signIn(SocialProvider.google);

    expect(vm.toastMessage, AppErrorMessages.loginCancelled);
    expect(vm.toastIsError, isFalse);
    expect(vm.toastRetryable, isFalse);
    expect(vm.outcome, isNull);
  });

  test('실패하면 오류 토스트와 다시 시도, retry는 같은 provider로 다시 시도한다', () async {
    authRepo.signInError = const SocialSignInFailedException();
    final vm = build();

    await vm.signIn(SocialProvider.google);
    expect(vm.toastMessage, AppErrorMessages.loginFailed);
    expect(vm.toastRetryable, isTrue);

    authRepo.signInError = null;
    await vm.retry();
    expect(authRepo.lastProvider, SocialProvider.google);
    expect(vm.outcome, isA<LoginToHome>());
  });

  test('로딩 중에는 두 번째 요청을 무시한다', () async {
    final vm = build();
    final first = vm.signIn(SocialProvider.google);
    expect(vm.isLoading, isTrue);
    await vm.signIn(SocialProvider.apple);
    await first;

    expect(authRepo.lastProvider, SocialProvider.google);
  });
}
