abstract interface class UserApi {
  Future<void> createUser({required String preference});
  Future<void> deleteUser();
}
