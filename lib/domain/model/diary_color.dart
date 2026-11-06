/// 일기의 추천 색상. 이름은 서버가 못 줄 수 있다(그러면 hex를 이름 자리에 보여준다).
class DiaryColor {
  final String? name;
  final String hex;

  const DiaryColor({required this.hex, this.name});

  static const DiaryColor fallbackFirst = DiaryColor(hex: '#8196C3');
  static const DiaryColor fallbackSecond = DiaryColor(hex: '#EEB5BE');
}
