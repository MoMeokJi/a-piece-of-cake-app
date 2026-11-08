/// 서버 푸시의 `data.type`. 서버 FcmService와 값이 같다.
enum PushType {
  feedback('FEEDBACK'),
  remind('REMIND'),
  adminMessage('ADMIN_MESSAGE'),
  unknown('');

  const PushType(this.code);
  final String code;

  static PushType fromCode(Object? code) {
    for (final type in values) {
      if (type != unknown && type.code == code) return type;
    }
    return unknown;
  }
}

/// 푸시 한 건의 `data`. 탭과 포그라운드 수신 양쪽에 같은 형식으로 쓴다. 어디로 갈지는 presentation이 정한다.
class PushPayload {
  final PushType type;

  /// `FEEDBACK`일 때만 있다. 서버는 문자열로 보낸다.
  final int? diaryId;

  const PushPayload({required this.type, this.diaryId});

  /// 이 일기의 시식평 알림인가
  bool isFeedbackFor(int? id) =>
      type == PushType.feedback && diaryId != null && diaryId == id;

  /// FCM `data` 또는 로컬 알림 payload(같은 형식)에서 만든다.
  factory PushPayload.fromData(Map<String, dynamic> data) {
    return PushPayload(
      type: PushType.fromCode(data['type']),
      diaryId: int.tryParse(data['diaryId']?.toString() ?? ''),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PushPayload &&
      other.type == type &&
      other.diaryId == diaryId;

  @override
  int get hashCode => Object.hash(type, diaryId);

  @override
  String toString() => 'PushPayload(type: $type, diaryId: $diaryId)';
}
