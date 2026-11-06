import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_response_dto.dart';
import 'package:cake/data/dto/diary_list_response_dto.dart';
import 'package:cake/data/dto/diary_page_response_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/model/local_image.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:dio/dio.dart';

class DiaryApiImpl implements DiaryApi {
  final Dio _dio;

  DiaryApiImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DiaryPageResponseDto> fetchDiaryPage({
    required String sort,
    required int page,
    required int size,
  }) async {
    final response = await _dio.get(
      '/diaries',
      queryParameters: {'sort': sort, 'page': page, 'size': size},
    );
    final body = response.data;
    // 서버가 객체 형식으로 바뀌기 전 배포본(배열)도 받아준다.
    if (body is List) {
      return DiaryPageResponseDto(
        items: body
            .map((e) => DiaryListResponseDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: page,
        size: size,
        hasNext: body.length >= size,
        totalCount: null,
      );
    }
    return DiaryPageResponseDto.fromJson(body as Map<String, dynamic>);
  }

  @override
  Future<List<DiaryListResponseDto>> fetchMonthlyDiaries({
    required int year,
    required int month,
    required String sort,
  }) async {
    final response = await _dio.get(
      '/diaries/calendar',
      queryParameters: {'year': year, 'month': month, 'sort': sort},
    );
    return (response.data as List)
        .map((e) => DiaryListResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DiaryDetailResponseDto> _createDiary({
    required String path,
    required String text,
    required List<LocalImage> images,
    required String endpointName,
  }) async {
    final formData = FormData.fromMap({
      // 일반 String으로 넣으면 FormData.fields로 가서 content-type이 붙지 않는다.
      // 서버는 비ASCII 본문에 `text/plain; charset=utf-8` 선언을 기대해 왔으므로
      // MultipartFile로 감싸 같은 선언을 유지한다.
      'text': MultipartFile.fromString(
        text,
        contentType: DioMediaType('text', 'plain', {'charset': 'utf-8'}),
      ),
      'images': [
        for (final image in images)
          await MultipartFile.fromFile(
            image.path,
            contentType: DioMediaType('application', 'octet-stream'),
          ),
      ],
    });

    final response = await _dio.post(path, data: formData);
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return DiaryDetailResponseDto.fromJson(body);
    }

    throw ApiException(
      statusCode: response.statusCode ?? -1,
      endpoint: endpointName,
      responseBody: response.data?.toString() ?? '',
    );
  }

  @override
  Future<DiaryDetailResponseDto> createQnaDiary({
    required String text,
    required List<LocalImage> images,
  }) => _createDiary(
    path: '/diaries',
    text: text,
    images: images,
    endpointName: 'createQnaDiary',
  );

  @override
  Future<DiaryDetailResponseDto> createFreeDiary({
    required String text,
    required List<LocalImage> images,
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
      // 응답을 받은 실패에만 fallback을 적용한다. 오프라인은 그대로 올려보낸다 —
      // 기본 질문을 주면 답을 다 쓴 뒤 생성 요청에서 실패하기 때문.
      if (e.response == null) rethrow;
      AppLogger.error(
        'fetchQuestions 서버 에러. statusCode : ${e.response?.statusCode}',
      );
      return const [
        '지금 기분이 어때?',
        '오늘 특별한 일이나 기록하고 싶은 일이 있었어?',
        '요즘 너의 최대 관심사는 뭐야?',
        '오늘 가장 후회되는 지출이 있어? 꼭 오늘이 아니어도 괜찮아',
        '오늘의 너에게 해주고 싶은 말이 있다면?',
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
  Future<DiaryDetailResponseDto> fetchDiary({required int id}) async {
    final response = await _dio.get('/diaries/$id');
    return DiaryDetailResponseDto.fromJson(
      response.data as Map<String, dynamic>,
    );
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
