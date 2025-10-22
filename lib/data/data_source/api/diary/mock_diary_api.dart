import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/music_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:image_picker/image_picker.dart';

class MockDiaryApi implements DiaryApi {
  @override
  Future<DiaryDetailDto> createDiary({
    required String text,
    required List<XFile> images,
  }) async {
    await Future.delayed(Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    return DiaryDetailDto(
      diaryId: 214,
      content: text,
      createdAt: DateTime.now().toIso8601String(),

      images: ['https://picsum.photos/600/400'],
      colors: ['#8196C3', '#EEB5BE'],
      music: MusicDto(
        title: 'blue valentine',
        artist: '엔믹스',
        youtubeUrl: 'https://www.youtube.com/watch?v=EmeW6li6bbo',
      ),
      summary: '오늘은 좋은 하루였습니다.',
    );
  }

  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) async {
    await Future.delayed(Duration(milliseconds: 800));

    return DiaryDetailDto(
      diaryId: id,
      content: '메인에서 넘어왔어요 오늘은 프로젝트를 열심히 했어요. 힘들었지만 보람찼습니다.',
      createdAt: '2025-10-16T14:30:00Z',
      images: [
        'https://picsum.photos/600/400',
        'https://picsum.photos/600/400',
      ],
      colors: ['#C3E9A6', '#B19CD9'],
      music: MusicDto(
        title: 'blue valentine',
        artist: '엔믹스',
        youtubeUrl: 'https://www.youtube.com/watch?v=EmeW6li6bbo',
      ),
      feedbackMsg: '',
    );
  }

  @override
  Future<String> requestQnaDiary({
    required List<QnaRequestDto> qnaListDto,
  }) async {
    await Future.delayed(Duration(seconds: 2));

    return '''오늘은 평범한 하루였어요. 
특별한 일은 없었지만, 프로젝트를 완성하기 위해 열심히 노력했습니다.
내일도 화이팅!''';
  }

  @override
  Future<void> deleteDiary({required int id}) async {
    await Future.delayed(Duration(milliseconds: 500));
    // 삭제 완료
  }
}
