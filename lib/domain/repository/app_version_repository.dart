import 'package:cake/domain/model/app_version_info.dart';

abstract interface class AppVersionRepository {
  /// 내 플랫폼의 최소 버전 정보. 서버에 등록이 없거나 조회 실패면 null (업데이트 강제 안 함).
  Future<AppVersionInfo?> getVersionInfo();

  /// pubspec의 x.y.z
  Future<String> getCurrentVersion();

  /// 스토어 페이지를 연다. url이 없으면 플랫폼 기본 스토어 링크.
  Future<void> openStore(String? url);
}
