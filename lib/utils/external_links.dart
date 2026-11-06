import 'package:cake/utils/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLinks {
  ExternalLinks._();

  static Future<void> open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppLogger.error('링크 열기 실패: $url $e');
    }
  }
}
