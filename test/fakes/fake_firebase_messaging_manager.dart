import 'dart:async';

import 'package:cake/data/data_source/firebase/messaging/firebase_messaging_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FakeFirebaseMessagingManager implements FirebaseMessagingManager {
  final onMessageController = StreamController<RemoteMessage>.broadcast();
  final onOpenedController = StreamController<RemoteMessage>.broadcast();
  final tokenRefreshController = StreamController<String>.broadcast();
  RemoteMessage? initialMessage;
  String? token = 'fcm-token';
  int requestPermissionCalls = 0;
  int deleteTokenCalls = 0;

  @override
  Future<void> requestPermission() async => requestPermissionCalls++;

  @override
  Future<void> setForegroundPresentationOptions() async {}

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async => deleteTokenCalls++;

  @override
  Stream<RemoteMessage> get onMessage => onMessageController.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => onOpenedController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    final message = initialMessage;
    initialMessage = null;
    return message;
  }

  @override
  Stream<String> get onTokenRefresh => tokenRefreshController.stream;
}
