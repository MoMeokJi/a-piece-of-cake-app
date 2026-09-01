import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class DiaryApiImpl implements DiaryApi {
  final Dio _dio;

  DiaryApiImpl({required Dio dio}) : _dio = dio;

  Future<DiaryDetailDto> _createDiary({
    required String path,
    required String text,
    required List<XFile> images,
    required String endpointName,
  }) async {
    final formData = FormData.fromMap({
      // 일반 String으로 넣으면 FormData.fields로 가서 content-type이 붙지 않는다.
      // 옛 http 구현은 비ASCII 값(한글 본문)에 항상
      // `content-type: text/plain; charset=utf-8`을 실어 보냈다
      // (package:http MultipartRequest._headerForField). 서버가 이 선언에
      // 의존해 왔을 수 있으므로 MultipartFile로 감싸 같은 선언을 유지한다.
      'text': MultipartFile.fromString(
        text,
        contentType: DioMediaType('text', 'plain', {'charset': 'utf-8'}),
      ),
      'images': [
        for (final image in images) await MultipartFile.fromFile(image.path),
      ],
    });

    final response = await _dio.post(path, data: formData);

    if (response.statusCode == 201) {
      return DiaryDetailDto.fromJson(response.data as Map<String, dynamic>);
    }

    // dio의 기본 validateStatus는 2xx만 통과시키므로 4xx/5xx는 여기 오기 전에
    // DioException으로 던져진다. 이 분기는 200/202/204처럼 2xx이지만 201이
    // 아닌 응답에서만 실행된다 (auth_interceptor.dart:130-131과 동일한 패턴).
    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: endpointName,
      responseBody: response.data?.toString() ?? '',
    );
  }

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  }) => _createDiary(
    path: '/diaries',
    text: text,
    images: images,
    endpointName: 'createQnaDiary',
  );

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  }) => _createDiary(
    path: '/diaries/free',
    text: text,
    images: images,
    endpointName: 'createFreeDiary',
  );

  @override
  Future<List<String>> fetchQuestions() async {
    try {
      final response = await _dio.get('/diaries/question');
      return List<String>.from(response.data['questions']);
    } on DioException catch (e) {
      // 응답을 받은 실패에만 fallback을 적용한다.
      // 네트워크 단절/타임아웃은 기존처럼 예외로 올려보낸다 — 오프라인 사용자에게
      // 기본 질문을 주면 답을 다 쓴 뒤 generateQnaDiary에서 실패한다.
      if (e.response == null) rethrow;

      // 서버 에러를 사용자에게 보여주기보다 기본 질문으로 대체한다.
      AppLogger.error(
        'fetchQuestions 서버 에러. statusCode : ${e.response?.statusCode}',
      );
      return [
        "지금 기분이 어때?",
        "오늘 특별한 일이나 기록하고 싶은 일이 있었어? ",
        "요즘 너의 최대 관심사는뭐야?",
        "오늘 가장 후회되는 지출이 있어? 꼭 오늘이 아니어도 괜찮아",
        "오늘의 너에게 해주고 싶은 말이 있다면?",
      ];
    }
  }

  @override
  Future<String> requestQnaDiary({
    required List<QnaRequestDto> qnaListDto,
  }) async {
    final response = await _dio.post(
      '/diaries/qna',
      data: {'target_set': qnaListDto.map((qna) => qna.toJson()).toList()},
    );

    return response.data['content'] as String;
  }

  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) async {
    final response = await _dio.get('/diaries/$id');
    return DiaryDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDiary({required int id}) async {
    await _dio.delete('/diaries/$id');
  }

  @override
  Future<void> updateDiaryText({required int id, required String text}) async {
    await _dio.patch('/diaries/$id', data: {'text': text});
  }
}
