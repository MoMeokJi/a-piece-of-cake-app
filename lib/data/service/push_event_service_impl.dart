import 'dart:async';

import 'package:cake/domain/model/push_payload.dart';
import 'package:cake/domain/service/push_event_service.dart';
import 'package:cake/utils/app_logger.dart';

class PushEventServiceImpl implements PushEventService {
  final _controller = StreamController<PushPayload>.broadcast();
  final _received = StreamController<PushPayload>.broadcast();
  PushPayload? _pending;

  @override
  void publish(PushPayload tap) {
    AppLogger.log('푸시 탭: $tap', tag: 'FCM');
    if (_controller.hasListener) {
      _controller.add(tap);
    } else {
      _pending = tap;
    }
  }

  @override
  Stream<PushPayload> get taps => _controller.stream;

  @override
  PushPayload? takePending() {
    final tap = _pending;
    _pending = null;
    return tap;
  }

  @override
  void publishReceived(PushPayload payload) {
    AppLogger.log('푸시 수신(포그라운드): $payload', tag: 'FCM');
    _received.add(payload);
  }

  @override
  Stream<PushPayload> get received => _received.stream;
}
