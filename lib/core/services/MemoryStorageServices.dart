class MemoryStorageService {
  String? _authToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;

  void setToken(String token) {
    _authToken = token;
  }

  void setRefreshToken(String refreshToken) {
    _refreshToken = refreshToken;
  }

  void setUserData(Map<String, dynamic> userData) {
    _userData = userData;
  }

  String? getToken() {
    return _authToken;
  }

  String? getRefreshToken() {
    return _refreshToken;
  }

  Map<String, dynamic>? getUserData() {
    return _userData;
  }
}
