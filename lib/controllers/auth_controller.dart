import '../connections/auth_api.dart';
import '../connections/user_api.dart';
import '../utils/jwt_storage.dart';

class AuthController {
  final AuthApi _authApi = AuthApi();
  final UserApi _userApi = UserApi();

  Future<bool> login(String email, String password) async {
    try {
      final token = await _authApi.login(email, password);
      await JwtStorage.saveToken(token);

      final user = await _userApi.getUserByEmail(email);
      await JwtStorage.saveUserId(user.id!);
      await JwtStorage.saveUsername(user.name!);
      await JwtStorage.saveEmail(user.email);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await _authApi.register(name, email, password);
      

      return await login(email, password);
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async => await JwtStorage.clearAll();
}
