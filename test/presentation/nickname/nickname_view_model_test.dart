import 'package:cake/domain/exception/app_exception.dart';
import 'package:cake/presentation/common/nickname_validator.dart';
import 'package:cake/presentation/common/profile_change_notifier.dart';
import 'package:cake/presentation/nickname/nickname_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_app_prefs_repository.dart';
import '../../fakes/fake_auth_repository.dart';
import '../../fakes/fake_user_repository.dart';

void main() {
  late FakeUserRepository userRepo;
  late FakeAuthRepository authRepo;
  late FakeAppPrefsRepository prefsRepo;

  late ProfileChangeNotifier profileChanges;
  late int profileChangeCount;

  setUp(() {
    userRepo = FakeUserRepository();
    authRepo = FakeAuthRepository();
    prefsRepo = FakeAppPrefsRepository();
    profileChanges = ProfileChangeNotifier();
    profileChangeCount = 0;
    profileChanges.addListener(() => profileChangeCount++);
  });

  NicknameViewModel build({bool isOnboarding = true, String? initial}) =>
      NicknameViewModel(
        userRepo: userRepo,
        authRepo: authRepo,
        prefsRepo: prefsRepo,
        profileChanges: profileChanges,
        isOnboarding: isOnboarding,
        initialNickname: initial,
      );

  test('저장에 성공하면 프로필 변경을 알린다 (홈 인사말 갱신용)', () async {
    final vm = build(isOnboarding: false, initial: '서윤');
    vm.controller.text = '케이크';
    await vm.save();
    expect(vm.saved, isTrue);
    expect(profileChangeCount, 1);
  });

  test('저장에 실패하면 프로필 변경을 알리지 않는다', () async {
    userRepo.nicknameError = Exception('boom');
    final vm = build(isOnboarding: false, initial: '서윤');
    vm.controller.text = '케이크';
    await vm.save();
    expect(vm.saved, isFalse);
    expect(profileChangeCount, 0);
  });

  group('validateNickname', () {
    test('규칙: 완성형 한글·영문·숫자 2~10자', () {
      expect(validateNickname('서윤'), NicknameValidation.valid);
      expect(validateNickname('cake123'), NicknameValidation.valid);
      expect(validateNickname(''), NicknameValidation.empty);
      expect(validateNickname('서'), NicknameValidation.tooShort);
      expect(validateNickname('케이크러버케이크러버케'), NicknameValidation.tooLong);
      expect(validateNickname('케이크!!'), NicknameValidation.invalidChars);
      expect(validateNickname('ㄱㄴ'), NicknameValidation.invalidChars);
      expect(validateNickname('서 윤'), NicknameValidation.invalidChars);
    });
  });

  test('SDK 이름을 미리 채우고 바로 저장할 수 있다', () {
    final vm = build(initial: '서윤');
    expect(vm.prefilledFromProvider, isTrue);
    expect(vm.canSave, isTrue);
    expect(vm.showError, isFalse);
  });

  test('입력이 바뀌면 검증 상태가 따라간다', () {
    final vm = build();
    expect(vm.canSave, isFalse);
    expect(vm.showError, isFalse, reason: '비어 있을 땐 오류를 보이지 않는다');

    vm.controller.text = '케이크!!';
    expect(vm.showError, isTrue);
    expect(vm.validation.message, '한글, 영문, 숫자만 쓸 수 있어요');

    vm.controller.text = '케이크러버';
    expect(vm.canSave, isTrue);
  });

  test('가입 흐름: 저장 뒤 보관된 알림 선택을 보내고 FCM 토큰을 등록한다', () async {
    prefsRepo.pendingNotificationOptIn = true;
    final vm = build(initial: '서윤');

    await vm.save();

    expect(userRepo.savedNicknames, ['서윤']);
    expect(userRepo.notificationUpdates, [true]);
    expect(prefsRepo.pendingNotificationOptIn, isNull);
    expect(authRepo.registerFcmCallCount, 1);
    expect(vm.saved, isTrue);
  });

  test('알림을 끄고 가입하면 알림 API를 부르지 않는다 (기본 꺼짐)', () async {
    prefsRepo.pendingNotificationOptIn = false;
    final vm = build(initial: '서윤');

    await vm.save();

    expect(userRepo.notificationUpdates, isEmpty);
  });

  test('변경 흐름: 저장만 하고 알림·FCM은 건드리지 않는다', () async {
    final vm = build(isOnboarding: false, initial: '서윤');
    vm.controller.text = '케이크러버';

    await vm.save();

    expect(userRepo.savedNicknames, ['케이크러버']);
    expect(authRepo.registerFcmCallCount, 0);
    expect(vm.saved, isTrue);
  });

  test('서버가 VALIDATION_FAILED면 형식 안내 토스트', () async {
    userRepo.nicknameError = const ValidationFailedException();
    final vm = build(initial: '서윤');

    await vm.save();

    expect(vm.saved, isFalse);
    expect(vm.toastMessage, '닉네임 형식을 확인해 주세요');
  });
}
