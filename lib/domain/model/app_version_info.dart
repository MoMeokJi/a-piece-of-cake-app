/// `GET /app/min-version`의 내 플랫폼 항목. 서버에 등록되지 않은 플랫폼이면 null이 온다.
class AppVersionInfo {
  final String minVersion;
  final String? latestVersion;
  final String? storeUrl;

  const AppVersionInfo({
    required this.minVersion,
    this.latestVersion,
    this.storeUrl,
  });
}
