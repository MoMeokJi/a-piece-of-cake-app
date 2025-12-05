import 'package:cake/domain/service/permission_handler_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerServiceImpl implements PermissionHandlerService {
  bool _hasNotificationPermission = false;

  @override
  Future<void> requestEssentialPermissions() async {
    AppLogger.log('필수 권한 요청 시작');
    await Permission.notification.request();
  }

  @override
  Future<bool> checkNotificationPermission() async {
    AppLogger.log('알림 권한 : ${await Permission.notification.isGranted}');
    return await Permission.notification.isGranted;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final permission = await Permission.notification.request();
    if (permission.isGranted) {
      _hasNotificationPermission = true;
    } else {
      _hasNotificationPermission = false;
      AppLogger.log('권한 설정 화면 열기');
      openAppSettings();
    }
    AppLogger.log('알림 권한 요청 함. 권한 상태 : $_hasNotificationPermission');
    return _hasNotificationPermission;
  }

  @override
  Future<bool> requestPermission(Permission permission) async {
    if (await permission.isDenied && !await permission.isPermanentlyDenied) {
      final status = await permission.request();
      if (!status.isGranted) {
        AppLogger.log('권한 설정 화면 열기');
        openAppSettings();
      }
      AppLogger.log(
        '${permission.toString()} 권한 요청 함. 권한 상태 : ${status.isGranted}',
      );
      return status.isGranted;
    }
    bool isGranted = await permission.isGranted;
    AppLogger.log('${permission.toString()} 권한 이미 있음. 권한 상태 : $isGranted');
    return isGranted;
  }

  @override
  Future<bool> checkPermission(Permission permission) async {
    bool isGranted = await permission.isGranted;
    AppLogger.log('${permission.toString()} 권한 확인 : $isGranted');
    return isGranted;
  }

  @override
  Future<bool> isPermanentlyDenied(Permission permission) async {
    bool isPermanentlyDenied = await permission.isPermanentlyDenied;
    AppLogger.log(
      '${permission.toString()} 권한 영구 거부 여부 : $isPermanentlyDenied',
    );
    return isPermanentlyDenied;
  }
}
