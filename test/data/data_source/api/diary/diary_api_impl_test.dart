import 'dart:convert';
import 'dart:typed_data';

import 'package:cake/data/data_source/api/diary/diary_api_impl.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 요청 본문 바이트를 그대로 캡처하는 fake adapter.
/// FormData의 실제 wire 포맷(part 헤더 포함)을 검증하려면 dio가 만든
/// requestStream을 직접 읽어야 한다 — RequestOptions.data만 봐서는
/// finalize() 이후의 바이트를 알 수 없다.
class _CapturingAdapter implements HttpClientAdapter {
  Uint8List? capturedBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final chunks = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        chunks.addAll(chunk);
      }
    }
    capturedBody = Uint8List.fromList(chunks);

    return ResponseBody.fromString(
      '{}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    '한글 본문(text)을 MultipartFile로 보내 charset=utf-8 content-type을 싣는다',
    () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;
      final api = DiaryApiImpl(dio: dio);

      await api.createFreeDiary(text: '안녕하세요', images: const <LocalImage>[]);

      final body = utf8.decode(adapter.capturedBody!, allowMalformed: true);

      // text 파트의 헤더 블록만 잘라 확인한다: 다음 boundary(--)가 오기 전까지.
      final textPartStart = body.indexOf('name="text"');
      expect(textPartStart, greaterThanOrEqualTo(0), reason: 'text 파트가 없음');
      final headerEnd = body.indexOf('\r\n\r\n', textPartStart);
      final textPartHeaders = body.substring(
        body.lastIndexOf('\r\n', textPartStart) + 2,
        headerEnd,
      );

      expect(
        textPartHeaders,
        contains('content-disposition: form-data; name="text"'),
      );
      // 옛 http 구현이 비ASCII 값에 항상 실어 보내던 선언과 동일해야 한다.
      expect(
        textPartHeaders,
        contains('content-type: text/plain; charset=utf-8'),
      );
      // filename이 실리면 안 된다 — MultipartFile로 옮기며 생길 수 있는 회귀.
      expect(textPartHeaders, isNot(contains('filename')));

      // 본문 바이트 자체도 그대로 보존되는지 확인.
      expect(body, contains('안녕하세요'));
    },
  );
}
