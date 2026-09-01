import 'dart:convert';

import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/base_api.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/domain/repository/token_repository.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiaryApiImpl extends BaseApi implements DiaryApi {
  final Dio _dio;

  DiaryApiImpl({required Dio dio, required TokenRepository tokenRepository})
    : _dio = dio,
      super(tokenRepository);

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse('${ApiConfig.baseUrl}/diaries'),
    )..headers.addAll(await getHeaders());

    request.fields['text'] = text;

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', image.path),
      );
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 201) {
      // StreamedResponse를 Response로 변환 (multipartFile을 쓰면 StreamedResponse로 리턴됨.)
      final response = await http.Response.fromStream(streamedResponse);
      await saveAllTokensFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      return DiaryDetailDto.fromJson(jsonData);
    } else if (streamedResponse.statusCode == 401) {
      await reissueTokens();
      return createQnaDiary(text: text, images: images);
    } else {
      throw await ApiException.fromStreamedResponse(
        streamedResponse,
        'createQnaDiary',
      );
    }
  }

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse('${ApiConfig.baseUrl}/diaries/free'),
    )..headers.addAll(await getHeaders());

    request.fields['text'] = text;

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', image.path),
      );
    }

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 201) {
      // StreamedResponse를 Response로 변환 (multipartFile을 쓰면 StreamedResponse로 리턴됨.)
      final response = await http.Response.fromStream(streamedResponse);
      await saveAllTokensFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      return DiaryDetailDto.fromJson(jsonData);
    } else if (streamedResponse.statusCode == 401) {
      await reissueTokens();
      return createFreeDiary(text: text, images: images);
    } else {
      throw await ApiException.fromStreamedResponse(
        streamedResponse,
        'createFreeDiary',
      );
    }
  }

  @override
  Future<List<String>> fetchQuestions() async {
    final response = await _dio.get('/diaries/question');

    return List<String>.from(response.data['questions']);
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
  Future<void> updateDiaryText({
    required int id,
    required String text,
  }) async {
    await _dio.patch('/diaries/$id', data: {'text': text});
  }
}
