import 'dart:io';

import 'package:cake/config/app_config.dart';
import 'package:cake/data/data_source/api/app_version/app_version_api.dart';
import 'package:cake/domain/model/app_version_info.dart';
import 'package:cake/domain/repository/app_version_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionApi _api;

  AppVersionRepositoryImpl({required AppVersionApi api}) : _api = api;

  @override
  Future<AppVersionInfo?> getVersionInfo() async {
    try {
      final dto = await _api.fetchMinVersion();
      final mine = Platform.isIOS ? dto.ios : dto.android;
      final min = mine?.minVersion;
      if (min == null || min.isEmpty) return null;
      return AppVersionInfo(
        minVersion: min,
        latestVersion: mine?.latestVersion,
        storeUrl: mine?.storeUrl,
      );
    } catch (e) {
      // 버전 조회 실패로 앱을 막지 않는다.
      AppLogger.error('최소 버전 조회 실패(무시): $e');
      return null;
    }
  }

  @override
  Future<String> getCurrentVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  @override
  Future<void> openStore(String? url) async {
    final target = (url != null && url.isNotEmpty) ? url : _defaultStoreUrl();
    if (target.isEmpty) return;
    try {
      await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('스토어 열기 실패: $e');
    }
  }

  String _defaultStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=${AppConfig.bundleId}';
    }
    if (Platform.isIOS && AppConfig.iosAppId.isNotEmpty) {
      return 'https://apps.apple.com/app/id${AppConfig.iosAppId}';
    }
    return '';
  }
}
