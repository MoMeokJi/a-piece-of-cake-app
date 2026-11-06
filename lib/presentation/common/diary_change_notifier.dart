import 'package:flutter/foundation.dart';

/// 일기가 생성·수정·삭제됐음을 홈에 알린다. 쓰기 화면 ViewModel이 호출하고
/// HomeViewModel이 듣는다. 두 ViewModel이 서로를 몰라도 되게 하는 중간 다리.
class DiaryChangeNotifier extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}
