import 'package:cake/data/service/push_event_service_impl.dart';
import 'package:cake/domain/model/push_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tap = PushPayload(type: PushType.feedback, diaryId: 7);

  test('듣는 쪽이 없으면 보류했다가 한 번만 내준다', () {
    final service = PushEventServiceImpl();
    service.publish(tap);
    expect(service.takePending(), tap);
    expect(service.takePending(), isNull);
  });

  test('듣는 쪽이 있으면 스트림으로 흘리고 보류하지 않는다', () async {
    final service = PushEventServiceImpl();
    final received = <PushPayload>[];
    final sub = service.taps.listen(received.add);
    service.publish(tap);
    await Future<void>.delayed(Duration.zero);
    expect(received, [tap]);
    expect(service.takePending(), isNull);
    await sub.cancel();
  });

  test('나중 탭이 먼저 보류된 탭을 덮는다', () {
    final service = PushEventServiceImpl();
    service.publish(const PushPayload(type: PushType.remind));
    service.publish(tap);
    expect(service.takePending(), tap);
  });

  test('수신은 보류하지 않고 스트림으로만 흘린다', () async {
    final service = PushEventServiceImpl();
    final received = <PushPayload>[];
    final sub = service.received.listen(received.add);
    service.publishReceived(tap);
    await Future<void>.delayed(Duration.zero);
    expect(received, [tap]);
    expect(service.takePending(), isNull);
    await sub.cancel();
  });
}
