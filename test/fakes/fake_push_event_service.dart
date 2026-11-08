import 'dart:async';

import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/service/push_event_service.dart';

class FakePushEventService implements PushEventService {
  final controller = StreamController<PushPayload>.broadcast();
  final receivedController = StreamController<PushPayload>.broadcast();
  final List<PushPayload> publishedReceived = [];
  PushPayload? pending;
  final List<PushPayload> published = [];

  @override
  void publish(PushPayload tap) => published.add(tap);

  @override
  Stream<PushPayload> get taps => controller.stream;

  @override
  void publishReceived(PushPayload payload) => publishedReceived.add(payload);

  @override
  Stream<PushPayload> get received => receivedController.stream;

  @override
  PushPayload? takePending() {
    final tap = pending;
    pending = null;
    return tap;
  }
}
