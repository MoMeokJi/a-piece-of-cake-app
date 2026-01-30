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

    return '''오늘은 평범하면서도 의미 있는 하루였어요. 아침에 일어나자마자 창밖을 내다보니 날씨가 참 좋더라고요. 맑은 하늘을 보며 오늘 하루도 좋은 일들만 가득하길 바라는 마음으로 하루를 시작했습니다.

출근길에는 평소보다 조금 일찍 나섰는데, 덕분에 여유롭게 커피 한 잔을 마실 수 있었어요. 카페에 앉아 창밖을 바라보며 오늘 해야 할 일들을 머릿속으로 정리했습니다. 프로젝트 마감이 다가오고 있어서 조금 긴장되기도 했지만, 동시에 완성에 가까워지고 있다는 생각에 설레기도 했어요.

회사에 도착해서는 바로 업무에 집중했습니다. 어제 해결하지 못했던 버그를 오늘 아침에 드디어 찾아냈어요. 몇 시간 동안 고민했던 문제였는데, 막상 원인을 찾고 보니 아주 사소한 실수였더라고요. 이럴 때마다 느끼는 건데, 개발이라는 게 정말 인내심을 많이 필요로 하는 일인 것 같아요.

점심시간에는 동료들과 함께 회사 근처 맛집에 다녀왔습니다. 다들 프로젝트 때문에 바쁘고 지쳐있었지만, 맛있는 음식을 먹으며 이야기를 나누다 보니 스트레스가 많이 풀렸어요. 팀원들과 함께 일할 수 있다는 게 정말 감사한 일이라는 생각이 들었습니다.

오후에는 새로운 기능을 구현하는 데 집중했어요. 처음에는 어떻게 접근해야 할지 막막했는데, 차근차근 문제를 분해하고 하나씩 해결해 나가다 보니 점점 형태가 갖춰지더라고요. 코드가 예쁘게 동작하는 걸 보면서 작은 성취감을 느꼈습니다.

저녁 무렵에는 예상치 못한 이슈가 발생했어요. 서버와의 통신에서 간헐적으로 오류가 발생하는 문제였는데, 원인을 찾는 데 꽤 오랜 시간이 걸렸습니다. 퇴근 시간이 다 되어서야 문제를 해결할 수 있었어요. 조금 피곤하긴 했지만, 오늘 안에 해결할 수 있어서 다행이라는 생각이 들었습니다.

퇴근 후에는 집에 돌아와서 간단하게 저녁을 해먹었어요. 요리를 하면서 오늘 하루를 되돌아봤습니다. 힘들었던 순간도 있었지만, 동시에 많은 것을 배우고 성장할 수 있었던 하루였던 것 같아요.

저녁을 먹고 나서는 잠시 쉬면서 좋아하는 음악을 들었습니다. 조용한 시간을 가지니 마음이 차분해지고 평온해지더라고요. 이런 여유로운 시간이 있어야 내일을 위한 에너지를 충전할 수 있는 것 같아요.

잠들기 전에 내일 할 일들을 간단히 정리했습니다. 프로젝트 마감까지 이제 며칠 남지 않았지만, 오늘처럼 차근차근 해나가다 보면 분명 좋은 결과가 있을 거라 믿어요. 때로는 힘들고 지칠 때도 있지만, 이 모든 과정이 저를 더 나은 개발자로 만들어주는 소중한 경험이라고 생각합니다.

내일은 또 어떤 하루가 펼쳐질지 기대되네요. 오늘보다 더 나은 내일이 되기를 바라며, 충분한 휴식을 취하고 내일을 맞이할 준비를 해야겠어요.''';
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

  @override
  Future<void> updateDiaryText({required int id, required String text}) {
    // TODO: implement updateDiaryText
    throw UnimplementedError();
  }
}
