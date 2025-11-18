import 'dart:convert';

import 'package:cake/config/api_config.dart';
import 'package:cake/data/data_source/api/api_exception.dart';
import 'package:cake/data/data_source/api/base_api.dart';
import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:cake/utils/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DiaryApiImpl extends BaseApi implements DiaryApi {
  DiaryApiImpl(super._tokenRepository);

  @override
  Future<DiaryDetailDto> createDiary({
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
      await saveAccessTokenFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      return DiaryDetailDto.fromJson(jsonData);
    } else if (streamedResponse.statusCode == 401) {
      await reissueTokens();
      return createDiary(text: text, images: images);
    } else {
      throw ApiException(streamedResponse.statusCode, 'createDiary 기타 에러');
    }
  }

  @override
  Future<List<String>> fetchQuestions() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/diaries/question'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      await saveAccessTokenFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(jsonData['questions']);
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return fetchQuestions();
    } else {
      // 여기서는 에러나면 굳이 그 에러를 보여주기보다는 defaultdata를 주는게 나을지도?
      AppLogger.error(
        'fetchQuestions 서버 에러. statusCode : ${response.statusCode}',
      );
      return [
        "지금 기분이 어때?",
        "오늘 특별한 일이나 기록하고 싶은 일이 있어?",
        "오늘 가장 아쉬운 점을 말해줘",
        "내일의 나에게 해주고 싶은 말이 있다면?",
        "오늘 널 가장 힘들게한 일이 뭐야?",
      ];
    }
  }

  @override
  Future<String> requestQnaDiary({
    required List<QnaRequestDto> qnaListDto,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/diaries/qna'),
      headers: await getHeaders(),
      body: jsonEncode({
        'target_set': qnaListDto.map((qna) => qna.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      await saveAccessTokenFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData['content'] as String;
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return requestQnaDiary(qnaListDto: qnaListDto);
    } else {
      throw ApiException(response.statusCode, 'requestQnaDiary 기타 에러');
    }
  }

  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/diaries/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      await saveAccessTokenFromHeader(response.headers);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return DiaryDetailDto.fromJson(jsonData);
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return fetchDiary(id: id);
    } else {
      throw ApiException(response.statusCode, 'fetchDiary 기타 에러');
    }
  }

  @override
  Future<void> deleteDiary({required int id}) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/diaries/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode == 204) {
      await saveAccessTokenFromHeader(response.headers);
    } else if (response.statusCode == 401) {
      await reissueTokens();
      return deleteDiary(id: id);
    } else {
      throw ApiException(response.statusCode, 'deleteDiary 기타 에러');
    }
  }
}
