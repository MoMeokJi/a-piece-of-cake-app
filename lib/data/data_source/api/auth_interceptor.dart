import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// 인증이 필요 없는 요청은 Options(extra: {AuthInterceptor.needsAuthKey: false})로 표시한다.
///
/// 401 처리 규칙 (서버 합의):
/// - TOKEN_EXPIRED → `/auth/refresh` 한 번 → 원요청 재시도
/// - TOKEN_INVALID · REFRESH_INVALID → refresh 없이 토큰을 지우고 세션 만료 통지
/// - 코드를 못 읽는 401 → refresh 한 번 시도
/// refresh는 single-flight다: 동시에 401이 여러 개 떨어져도 재발급은 한 번만 나간다.
class AuthInterceptor extends Interceptor {
  static const String needsAuthKey = 'needsAuth';

  final TokenRepository _tokenRepository;

  /// true인 인스턴스만 401을 처리한다. 재시도용·재발급용 Dio는 false여야 재귀가 없다.
  final bool _handleUnauthorized;
  final Dio? _retryDio;
  final Dio? _refreshDio;

  /// 토큰을 지운 뒤 호출. 로그인 화면으로 보내는 일은 config가 연결한다.
  final void Function()? _onSessionExpired;

  Future<void>? _inFlightRefresh;

  AuthInterceptor({
    required TokenRepository tokenRepository,
    required bool handleUnauthorized,
    Dio? retryDio,
    Dio? refreshDio,
    void Function()? onSessionExpired,
  }) : _tokenRepository = tokenRepository,
       _handleUnauthorized = handleUnauthorized,
       _retryDio = retryDio,
       _refreshDio = refreshDio,
       _onSessionExpired = onSessionExpired,
       assert(
         !handleUnauthorized || (retryDio != null && refreshDio != null),
         '401을 처리하려면 retryDio와 refreshDio가 필요하다',
       );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[needsAuthKey] != false) {
      final accessToken = await _tokenRepository.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_handleUnauthorized ||
        err.response?.statusCode != 401 ||
        err.requestOptions.extra[needsAuthKey] == false) {
      handler.next(err);
      return;
    }

    final code = ApiErrorCode.fromDioException(err);
    if (code == ApiErrorCode.tokenInvalid ||
        code == ApiErrorCode.refreshInvalid) {
      await _expireSession('401 $code');
      handler.next(err);
      return;
    }

    try {
      await _refreshSingleFlight();
    } catch (e) {
      AppLogger.error('토큰 재발급 실패: $e');
      if (_isSessionDead(e)) {
        await _expireSession('refresh 거부');
      } else {
        ApiException.reporter.recordError(
          e,
          StackTrace.current,
          reason: 'refreshTokens 실패',
        );
      }
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

  Future<void> _refreshSingleFlight() {
    final inFlight = _inFlightRefresh;
    if (inFlight != null) return inFlight;

    final future = _refreshTokens().whenComplete(() {
      _inFlightRefresh = null;
    });
    _inFlightRefresh = future;
    return future;
  }

  Future<void> _refreshTokens() async {
    AppLogger.log('토큰 만료. 재발급 요청');
    final refreshToken = await _tokenRepository.getRefreshToken();
    if (refreshToken == null) {
      throw const _NoRefreshToken();
    }
    final deviceId = await _tokenRepository.getOrCreateDeviceId();

    final response = await _refreshDio!.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken, 'deviceId': deviceId},
    );

    final body = response.data;
    final newAccess = body is Map ? body['accessToken'] : null;
    final newRefresh = body is Map ? body['refreshToken'] : null;
    if (newAccess is String && newRefresh is String) {
      await _tokenRepository.saveJwtTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return;
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: 'refreshTokens',
      responseBody: response.data?.toString() ?? '',
    );
  }

  bool _isSessionDead(Object e) {
    if (e is _NoRefreshToken) return true;
    if (e is DioException) {
      final status = e.response?.statusCode;
      final code = ApiErrorCode.fromDioException(e);
      return status == 401 ||
          status == 403 ||
          code == ApiErrorCode.refreshInvalid ||
          code == ApiErrorCode.tokenInvalid;
    }
    return false;
  }

  Future<void> _expireSession(String reason) async {
    AppLogger.log('세션 만료 ($reason). 토큰 삭제');
    await _tokenRepository.clearJwtTokens();
    _onSessionExpired?.call();
  }
}

class _NoRefreshToken implements Exception {
  const _NoRefreshToken();
}
