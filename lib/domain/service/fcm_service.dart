abstract interface class FCMService {
  Future<void> initialize();
  Future<void> getFCNTokenAndSave();
}
