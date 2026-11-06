import 'package:cake/data/dto/min_version_response_dto.dart';

abstract interface class AppVersionApi {
  Future<MinVersionResponseDto> fetchMinVersion();
}
