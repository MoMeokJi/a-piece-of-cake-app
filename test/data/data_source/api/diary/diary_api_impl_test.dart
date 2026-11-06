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
class _CapturingAdapter implements HttpClientAdapter {
  Uint8List? capturedBody;
  RequestOptions? capturedOptions;
  String responseJson = '{}';

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
      responseJson,
      200,
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
    '한글 본문(text)을 MultipartFile로 보내 charset=utf-8을 싣고, 이미지는 octet-stream',
    () async {
      final adapter = _CapturingAdapter()
        ..responseJson = jsonEncode({'diaryId': 1, 'type': 'FREE'});
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

      final dto = await api.createFreeDiary(
        text: '안녕하세요',
        images: [LocalImage(tempFile.path)],
      );
      expect(dto.diaryId, 1);
      expect(dto.type, 'FREE');

      final body = utf8.decode(adapter.capturedBody!, allowMalformed: true);
      final textPartStart = body.indexOf('name="text"');
      expect(textPartStart, greaterThanOrEqualTo(0));
      final headerEnd = body.indexOf('\r\n\r\n', textPartStart);
      final textPartHeaders = body.substring(
        body.lastIndexOf('\r\n', textPartStart) + 2,
        headerEnd,
      );
      expect(textPartHeaders, contains('content-type: text/plain; charset=utf-8'));
      expect(textPartHeaders, isNot(contains('filename')));
      expect(body, contains('안녕하세요'));

      final imagesPartStart = body.indexOf('name="images"');
      final imagesHeaderEnd = body.indexOf('\r\n\r\n', imagesPartStart);
      final imagesPartHeaders = body.substring(
        body.lastIndexOf('\r\n', imagesPartStart) + 2,
        imagesHeaderEnd,
      );
      expect(imagesPartHeaders, contains('content-type: application/octet-stream'));
    },
  );

  test('한글 본문을 PATCH할 때 JSON content-type에 charset=utf-8을 싣는다', () async {
    final adapter = _CapturingAdapter();
    final dio = buildDio(FakeTokenRepository(), adapter: adapter);
    final api = DiaryApiImpl(dio: dio);

    await api.updateDiaryText(id: 1, text: '한글 본문 수정');

    final sentContentType =
        adapter.capturedOptions!.headers[Headers.contentTypeHeader];
    expect(sentContentType, contains('charset=utf-8'));
    final decoded =
        jsonDecode(utf8.decode(adapter.capturedBody!)) as Map<String, dynamic>;
    expect(decoded['text'], '한글 본문 수정');
  });

  test('목록 조회는 sort·page·size를 항상 명시하고 객체 응답을 읽는다', () async {
    final adapter = _CapturingAdapter()
      ..responseJson = jsonEncode({
        'items': [
          {
            'diaryId': 7,
            'type': 'QNA',
            'summary': '요약',
            'createdAt': '2025-09-05T21:12:00+09:00',
            'colors': [
              {'name': '라벤더', 'hex': '#B19CD9'},
              {'name': null, 'hex': '#C3E9A6'},
            ],
            'music': {'title': 't', 'artist': 'a', 'videoId': 'v', 'durationSeconds': 182},
          },
        ],
        'page': 0,
        'size': 10,
        'hasNext': true,
        'totalCount': 24,
      });
    final api = DiaryApiImpl(
      dio: Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter,
    );

    final page = await api.fetchDiaryPage(sort: 'recent', page: 0, size: 10);

    expect(adapter.capturedOptions!.queryParameters, {
      'sort': 'recent',
      'page': 0,
      'size': 10,
    });
    expect(page.hasNext, isTrue);
    expect(page.totalCount, 24);
    expect(page.items!.single.colors![0].name, '라벤더');
    expect(page.items!.single.colors![1].name, isNull);
    expect(page.items!.single.music!.durationSeconds, 182);
  });

  test('목록 응답이 옛 배열 형식이어도 페이지로 감싼다', () async {
    final adapter = _CapturingAdapter()
      ..responseJson = jsonEncode([
        {'diaryId': 1, 'summary': 's', 'createdAt': '2025-09-05T21:12:00'},
      ]);
    final api = DiaryApiImpl(
      dio: Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter,
    );

    final page = await api.fetchDiaryPage(sort: 'recent', page: 0, size: 10);

    expect(page.items!.length, 1);
    expect(page.hasNext, isFalse);
  });
}
