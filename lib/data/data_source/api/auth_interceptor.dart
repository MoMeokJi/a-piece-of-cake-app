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

    // 재발급은 single-flight가 아니다: 동시에 여러 요청이 401을 받으면
    // 각각 독립적으로 재발급을 호출한다. TokenRepositoryImpl.saveJwtTokens는
    // access/refresh를 Future.wait로 병렬 저장하므로(원자적이지 않음),
    // 겹쳐 실행되는 재발급들이 뒤섞인 access/refresh 쌍을 남길 수 있다.
    // 오늘은 무해하다 — 인증이 필요한 요청을 동시에 여러 개 쏘는 경로가
    // 없고, 401에서 토큰을 지우지도 않는다. 나중에 API 호출을 병렬화하면
    // 이 인터셉터에 공유 in-flight Future<void>? 가드를 두어 해결한다.
    try {
      await _reissueTokens();
    } catch (e) {
      AppLogger.error('토큰 재발급 실패: $e');
      ApiException.reporter.recordError(
        e,
        StackTrace.current,
        reason: 'reissueTokens 실패',
      );
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
    // headers.value()는 헤더가 중복으로 오면 예외를 던진다(구 http 맵 병합과 다른
    // 실패 모드). 첫 값만 읽어 그 위험을 피한다.
    final rawAccessToken = headers['authorization']?.first;
    final refreshToken = headers['refresh-token']?.first;

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

    // dio의 기본 validateStatus는 2xx가 아니면 이미 DioException을 던지므로
    // 여기 도달할 수 있는 상태 코드는 200/201/202뿐이다(204는 위에서 처리).
    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'reissueTokens',
      responseBody: response.data?.toString() ?? '',
    );
  }
}
