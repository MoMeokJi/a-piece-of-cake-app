import 'package:cake/data/data_source/api/diary/diary_api.dart';
import 'package:cake/data/dto/diary_detail_dto.dart';
import 'package:cake/data/dto/music_dto.dart';
import 'package:cake/data/dto/qna_request_dto.dart';
import 'package:image_picker/image_picker.dart';

class MockDiaryApi implements DiaryApi {
  @override
  Future<DiaryDetailDto> fetchDiary({required int id}) async {
    await Future.delayed(Duration(milliseconds: 800));

    return DiaryDetailDto(
      diaryId: id,
      content:
          '''오늘은 정말 힘든 하루였다. 아침부터 비가 내려서 우울한 기분으로 하루를 시작했다. 지하철도 지연되고, 회사에 늦을 뻔했다.

오늘 프레젠테이션이 있었는데 너무 떨렸다. 밤새 준비했던 자료들을 발표하는 동안 손이 계속 떨렸고, 목소리도 제대로 나오지 않았다. 그런데 생각보다 팀장님이 좋게 봐주셔서 다행이었다.

점심시간에는 동료와 함께 새로 생긴 파스타집에 갔다. 토마토 크림파스타를 먹었는데 정말 맛있었다. 그 친구와 오랜만에 진솔한 대화를 나누면서 마음이 한결 가벼워졌다.

퇴근 후에는 헬스장에 갔다. 운동을 하면서 오늘 하루의 스트레스를 모두 땀으로 흘려보냈다. 집에 돌아와서는 따뜻한 차를 마시며 좋아하는 드라마를 봤다. 이런 소소한 일상의 행복이 얼마나 소중한지 새삼 느꼈다.''',
      createdAt: '2025-10-16T14:30:00Z',
      images: [
        'https://picsum.photos/600/400',
        'https://picsum.photos/600/400',
      ],
      colors: ['#C3E9A6', '#B19CD9'],
      music: MusicDto(
        title: 'blue valentine',
        artist: '엔믹스',
        videoId: 'EmeW6li6bbo',
      ),
      feedbackMsg:
          '힘든 하루를 보내셨군요. 프레젠테이션 긴장하셨을 텐데 팀장님이 좋게 봐주셔서 다행이에요! 동료와의 대화로 마음이 가벼워지고, 운동으로 스트레스를 해소하신 것도 정말 좋은 선택이었네요!',
    );
  }

  @override
  Future<String> requestQnaDiary({
    required List<QnaRequestDto> qnaListDto,
  }) async {
    await Future.delayed(Duration(seconds: 5));

    return '''오늘은 평범한 하루였어요. 
특별한 일은 없었지만, 프로젝트를 완성하기 위해 열심히 노력했습니다.
너무 힘들지만 그래도 내일은 내일의 해가 뜨겠지...''';
  }

  @override
  Future<void> deleteDiary({required int id}) async {
    await Future.delayed(Duration(milliseconds: 500));
    print('서버삭제완료');
    return;
  }

  @override
  Future<List<String>> fetchQuestions() async {
    final jsonData = {
      "questions": [
        "지금 기분이 어때?",
        "오늘 특별한 일이나 기록하고 싶은 일이 있어?",
        "오늘 가장 아쉬운 점을 말해줘",
        "내일의 나에게 해주고 싶은 말이 있다면?",
        "오늘 널 가장 힘들게한 일이 뭐야?",
      ],
    };

    // 네트워크 지연 시뮬레이션
    await Future.delayed(Duration(milliseconds: 500));

    return List<String>.from(jsonData['questions'] as List);
  }

  @override
  Future<DiaryDetailDto> createFreeDiary({
    required String text,
    required List<XFile> images,
  }) async {
    await Future.delayed(Duration(seconds: 5)); // 네트워크 지연 시뮬레이션

    return DiaryDetailDto(
      diaryId: 214,
      content: '자유일기입니다. $text',
      createdAt: DateTime.now().toIso8601String(),

      images: ['https://picsum.photos/600/400'],
      colors: ['#8196C3', '#EEB5BE'],
      music: MusicDto(
        title: 'blue valentine',
        artist: '엔믹스',
        videoId: 'EmeW6li6bbo',
      ),
      summary: '퇴사해야겠다 진짜로',
    );
  }

  @override
  Future<DiaryDetailDto> createQnaDiary({
    required String text,
    required List<XFile> images,
  }) async {
    await Future.delayed(Duration(seconds: 5)); // 네트워크 지연 시뮬레이션

    return DiaryDetailDto(
      diaryId: 214,
      content: '문답일기입니다. $text',
      createdAt: DateTime.now().toIso8601String(),

      images: ['https://picsum.photos/600/400'],
      colors: ['#8196C3', '#EEB5BE'],
      music: MusicDto(
        title: 'blue valentine',
        artist: '엔믹스',
        videoId: 'EmeW6li6bbo',
      ),
      summary: '퇴사해야겠다 진짜로',
    );
  }
}
