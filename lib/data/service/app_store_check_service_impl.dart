import 'dart:convert';
import 'dart:io';

import 'package:cake/config/app_config.dart';
import 'package:cake/domain/service/app_store_check_service.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppStoreCheckServiceImpl implements AppStoreCheckService {
  @override
  Future<bool> checkForUpdate() async {
    try {
      final currentVersion = await getCurrentVersion();
      final storeVersion = await getStoreVersion();

      if (storeVersion == null) {
        AppLogger.log('스토어 버전 정보를 가져올 수 없습니다. 업데이트 체크를 건너뜁니다.');
        return false;
      }

      final needsUpdate = currentVersion != storeVersion;
      AppLogger.log(
        '현재 버전: $currentVersion, 스토어 버전: $storeVersion, 업데이트 필요: $needsUpdate',
      );

      return needsUpdate;
    } catch (e) {
      AppLogger.error('업데이트 체크 중 오류 발생: $e');
      return false;
    }
  }

  @override
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      AppLogger.error('현재 앱 버전을 가져오는 중 오류 발생: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getStoreVersion() async {
    if (Platform.isAndroid) {
      return await _getPlayStoreVersion(AppConfig.bundleId);
    } else if (Platform.isIOS) {
      return await _getAppStoreVersion(AppConfig.bundleId);
    }
    return null;
  }

  @override
  Future<void> openStore() async {
    try {
      final storeUrl = _getStoreAppSchemeUrl();
      if (storeUrl.isNotEmpty) {
        final uri = Uri.parse(storeUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          AppLogger.log('스토어 열기 성공: $storeUrl');
        } else {
          AppLogger.error('스토어 열기 실패: $storeUrl');
        }
      }
    } catch (e) {
      AppLogger.error('스토어 열기 중 오류 발생: $e');
    }
  }

  String _getStoreAppSchemeUrl() {
    if (Platform.isAndroid) {
      return 'market://details?id=${AppConfig.bundleId}';
    } else if (Platform.isIOS) {
      return 'itms-apps://itunes.apple.com/app/apple-store/${AppConfig.iosAppId}';
    }
    return '';
  }

  /// Play Store에서 앱 버전 정보를 가져옴
  Future<String?> _getPlayStoreVersion(String packageName) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://play.google.com/store/apps/details?id=$packageName&gl=US",
        ),
      );
      if (response.statusCode == 200) {
        RegExp regexp = RegExp(
          r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]',
        );
        String? version = regexp.firstMatch(response.body)?.group(1);
        AppLogger.log('플레이스토어에서 추출된 버전 : $version');
        return version;
      }
    } catch (e) {
      AppLogger.error('Play Store 버전 정보 가져오기 실패: $e');
      return null;
    }
    return null;
  }

  /// App Store에서 앱 버전 정보를 가져옴
  Future<String?> _getAppStoreVersion(String bundleId) async {
    try {
      Uri uri = Uri.https("itunes.apple.com", "/lookup", {
        "bundleId": bundleId,
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonObj = json.decode(response.body);
        // 결과가 있는지 확인
        String? version = jsonObj['results'][0]['version'];
        AppLogger.log('앱스토어에서 추출된 버전 : $version');
        return version;
      }
    } catch (e) {
      AppLogger.error('App Store 버전 정보 가져오기 실패: $e');
    }
    return null;
  }
}
