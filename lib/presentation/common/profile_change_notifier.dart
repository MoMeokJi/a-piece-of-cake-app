import 'package:flutter/foundation.dart';

/// 프로필(닉네임)이 바뀌었음을 홈에 알린다. 닉네임 화면 ViewModel이 호출하고
/// HomeViewModel이 듣고 프로필을 다시 불러온다. [DiaryChangeNotifier]와 같은 역할.
class ProfileChangeNotifier extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}
