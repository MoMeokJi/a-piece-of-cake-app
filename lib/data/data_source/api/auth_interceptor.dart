import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// 인증이 필요 없는 요청은 Options(extra: {AuthInterceptor.needsAuthKey: false})로 표시한다.
class AuthInterceptor extends Interceptor {
  static const String needsAuthKey = 'needsAuth';

  final TokenRepository _tokenRepository;

  /// true인 인스턴스만 401을 처리한다.
  /// 재시도용 / 재발급용 Dio는 false여야 재귀가 생기지 않는다.
  final bool _handleUnauthorized;

  final Dio? _retryDio;
  final Dio? _reissueDio;

  AuthInterceptor({
    required TokenRepository tokenRepository,
    required bool handleUnauthorized,
    Dio? retryDio,
    Dio? reissueDio,
  }) : _tokenRepository = tokenRepository,
       _handleUnauthorized = handleUnauthorized,
       _retryDio = retryDio,
       _reissueDio = reissueDio,
       assert(
         !handleUnauthorized || (retryDio != null && reissueDio != null),
         '401을 처리하려면 retryDio와 reissueDio가 필요하다',
       );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[needsAuthKey] != false) {
      final accessToken = await _tokenRepository.getAccessToken();
      final refreshToken = await _tokenRepository.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        options.headers['Refresh-Token'] = refreshToken;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    await _saveTokensFromHeaders(response.headers);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_handleUnauthorized || err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    try {
      await _reissueTokens();
    } catch (e) {
      AppLogger.error('토큰 재발급 실패: $e');
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions;

      // 멀티파트 본문은 이미 소비되었으므로 복제해야 재전송할 수 있다.
      final data = options.data;
      if (data is FormData) {
        options.data = data.clone();
      }

      final retried = await _retryDio!.fetch(options);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _saveTokensFromHeaders(Headers headers) async {
    final rawAccessToken = headers.value('authorization');
    final refreshToken = headers.value('refresh-token');

    if (rawAccessToken != null && refreshToken != null) {
      await _tokenRepository.saveJwtTokens(
        accessToken: rawAccessToken.replaceFirst('Bearer ', ''),
        refreshToken: refreshToken,
      );
    }
  }

  Future<void> _reissueTokens() async {
    AppLogger.log('토큰 만료. 재발급 요청');
    final deviceId = await _tokenRepository.getFcmToken();

    final response = await _reissueDio!.post(
      '/auth/login',
      data: {'deviceId': deviceId},
    );

    if (response.statusCode == 204) {
      await _saveTokensFromHeaders(response.headers);
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'reissueTokens',
      responseBody: response.data?.toString() ?? '',
    );
  }
}
