import 'package:cake/data/data_source/api/app_version/app_version_api.dart';
import 'package:cake/data/data_source/api/auth_interceptor.dart';
import 'package:cake/data/dto/min_version_response_dto.dart';
import 'package:dio/dio.dart';

class AppVersionApiImpl implements AppVersionApi {
  final Dio _dio;

  AppVersionApiImpl({required Dio dio}) : _dio = dio;

  @override
  Future<MinVersionResponseDto> fetchMinVersion() async {
    final response = await _dio.get(
      '/app/min-version',
      options: Options(
        extra: {AuthInterceptor.needsAuthKey: false},
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    return MinVersionResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
