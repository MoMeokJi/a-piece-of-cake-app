import 'package:cake/domain/model/push_payload.dart';

/// 푸시 이벤트를 수신 측(FCM·로컬 알림)에서 presentation으로 넘긴다.
///
/// 탭: 듣는 쪽이 있으면 [taps]로 바로 흘리고, 없으면(앱이 알림으로 막 켜졌거나 로그인 전)
/// 보류해 두었다가 [takePending]으로 한 번 꺼내 간다. 메인 화면이 이동을, 열려 있는
/// 상세가 갱신을 맡는다.
/// 수신: 앱이 떠 있을 때 도착한 푸시는 [received]로만 흘린다. 보류하지 않는다.
abstract interface class PushEventService {
  void publish(PushPayload tap);

  Stream<PushPayload> get taps;

  /// 보류된 탭을 꺼내고 비운다. 없으면 null.
  PushPayload? takePending();

  void publishReceived(PushPayload payload);

  Stream<PushPayload> get received;
}
