import 'package:cake/domain/model/app_version_info.dart';
import 'package:cake/domain/repository/app_version_repository.dart';

class FakeAppVersionRepository implements AppVersionRepository {
  AppVersionInfo? info;
  String currentVersion = '1.0.0';
  final List<String?> openedStoreUrls = [];

  @override
  Future<AppVersionInfo?> getVersionInfo() async => info;

  @override
  Future<String> getCurrentVersion() async => currentVersion;

  @override
  Future<void> openStore(String? url) async => openedStoreUrls.add(url);
}
