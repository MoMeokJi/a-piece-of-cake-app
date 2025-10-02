import 'package:permission_handler/permission_handler.dart';

abstract interface class PermissionHandlerService {
  /// 필수 권한들 요청
  Future<void> requestEssentialPermissions();

  /// 알림 권한 요청
  Future<bool> requestNotificationPermission();

  /// 알림 권한 확인
  Future<bool> checkNotificationPermission();

  /// 단일 권한 요청
  Future<bool> requestPermission(Permission permission);

  /// 권한 상태 확인
  Future<bool> checkPermission(Permission permission);

  /// 권한이 영구적으로 거부되었는지 확인
  Future<bool> isPermanentlyDenied(Permission permission);
}
