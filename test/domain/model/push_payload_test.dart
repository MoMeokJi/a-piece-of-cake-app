import 'package:cake/domain/model/push_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('서버 data 형식(type, 문자열 diaryId)을 해석한다', () {
    final tap = PushPayload.fromData({
      'type': 'FEEDBACK',
      'diaryId': '42',
      'title': '제목',
      'body': '본문',
    });
    expect(tap, const PushPayload(type: PushType.feedback, diaryId: 42));
  });

  test('REMIND와 ADMIN_MESSAGE는 diaryId 없이 해석된다', () {
    expect(
      PushPayload.fromData({'type': 'REMIND'}),
      const PushPayload(type: PushType.remind),
    );
    expect(
      PushPayload.fromData({'type': 'ADMIN_MESSAGE'}),
      const PushPayload(type: PushType.adminMessage),
    );
  });

  test('모르는 type이나 깨진 diaryId는 unknown / null', () {
    expect(
      PushPayload.fromData({'type': 'SOMETHING'}).type,
      PushType.unknown,
    );
    expect(PushPayload.fromData({}).type, PushType.unknown);
    expect(
      PushPayload.fromData({'type': 'FEEDBACK', 'diaryId': 'abc'}),
      const PushPayload(type: PushType.feedback),
    );
  });
}
