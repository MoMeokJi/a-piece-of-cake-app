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
      diaryId: 1,
      content: text,
      createdAt: DateTime.now().toIso8601String(),

      images: [
        'https://picsum.photos/400/300?random=1',
        'https://picsum.photos/400/300?random=2',
        'https://picsum.photos/400/300?random=3',
      ],
      colors: ['#FF6B6B', '#4ECDC4'],
      music: MusicDto(
        title: '하루 끝',
        artist: '아이유',
        youtubeUrl: 'https://youtube.com/watch?v=abcd1234',
      ),
      feedbackMsg: '오늘도 수고했어요!',
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
        'https://picsum.photos/400/300?random=10',
        'https://picsum.photos/400/300?random=11',
      ],
      colors: ['#FFB6C1', '#87CEEB'],
      music: MusicDto(
        title: '좋은 날',
        artist: '아이유',
        youtubeUrl: 'https://youtube.com/watch?v=xyz789',
      ),
      feedbackMsg: '잘 하고 있어요!',
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
