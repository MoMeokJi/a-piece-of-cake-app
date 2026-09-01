import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cake/data/data_source/api/dio_client.dart';
import 'package:cake/data/data_source/api/diary/diary_api_impl.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_token_repository.dart';

/// 요청 본문 바이트를 그대로 캡처하는 fake adapter.
/// FormData의 실제 wire 포맷(part 헤더 포함)을 검증하려면 dio가 만든
/// requestStream을 직접 읽어야 한다 — RequestOptions.data만 봐서는
/// finalize() 이후의 바이트를 알 수 없다.
class _CapturingAdapter implements HttpClientAdapter {
  Uint8List? capturedBody;
  RequestOptions? capturedOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedOptions = options;
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
    '한글 본문(text)을 MultipartFile로 보내 charset=utf-8 content-type을 싣고, '
    '이미지 파트는 application/octet-stream을 싣는다',
    () async {
      final adapter = _CapturingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;
      final api = DiaryApiImpl(dio: dio);

      final tempFile = await File(
        '${Directory.systemTemp.path}/diary_api_impl_test_${DateTime.now().microsecondsSinceEpoch}.jpg',
      ).create();
      await tempFile.writeAsBytes([1, 2, 3, 4]);
      addTearDown(() async {
        if (await tempFile.exists()) await tempFile.delete();
      });

      await api.createFreeDiary(
        text: '안녕하세요',
        images: [LocalImage(tempFile.path)],
      );

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

      // images 파트의 헤더 블록도 잘라 확인한다.
      final imagesPartStart = body.indexOf('name="images"');
      expect(imagesPartStart, greaterThanOrEqualTo(0), reason: 'images 파트가 없음');
      final imagesHeaderEnd = body.indexOf('\r\n\r\n', imagesPartStart);
      final imagesPartHeaders = body.substring(
        body.lastIndexOf('\r\n', imagesPartStart) + 2,
        imagesHeaderEnd,
      );

      // http.MultipartFile.fromPath가 항상 보내던 application/octet-stream과
      // 같아야 한다 — dio의 fromFile 기본값(mime 추론, .jpg면 image/jpeg)으로
      // 조용히 바뀌면 안 된다.
      expect(
        imagesPartHeaders,
        contains('content-type: application/octet-stream'),
      );
      expect(imagesPartHeaders, isNot(contains('image/jpeg')));
    },
  );

  test('한글 본문을 PATCH할 때 JSON content-type에 charset=utf-8을 싣는다', () async {
    // updateDiaryText는 JSON 바디를 보낸다. package:http의 Request.body
    // setter는 charset이 없으면 항상 charset=utf-8을 붙였으므로, dio_client.dart의
    // _baseOptions()가 그 선언을 복원하는지 여기서 확인한다. 바로 dio_client의
    // buildDio를 거쳐야 실제로 배선된 헤더를 검증할 수 있다 (dio_client.dart:9 참고).
    final adapter = _CapturingAdapter();
    final dio = buildDio(FakeTokenRepository(), adapter: adapter);
    final api = DiaryApiImpl(dio: dio);

    await api.updateDiaryText(id: 1, text: '한글 본문 수정');

    final sentContentType =
        adapter.capturedOptions!.headers[Headers.contentTypeHeader];
    expect(sentContentType, contains('charset=utf-8'));
    expect(sentContentType, contains('application/json'));
  });
}
