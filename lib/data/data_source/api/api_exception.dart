import 'package:cake/utils/app_logger.dart';

class ApiException implements Exception {
  final int statusCode;
  final String technicalMessage;

  ApiException(this.statusCode, this.technicalMessage) {
    AppLogger.error('🔴 ApiException: $statusCode - $technicalMessage');
  }

  @override
  String toString() => 'ApiException: $statusCode - $technicalMessage';
}
