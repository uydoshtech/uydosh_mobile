abstract class IAuthTokenRepository {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens(String token);
  Future<bool> refreshTokens();
  Future<bool> hasTokens();
  Future<void> clearTokens();
}
