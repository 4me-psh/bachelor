import 'package:bachelor/connections/user_api.dart';
import 'package:bachelor/models/user.dart';
import 'package:bachelor/utils/jwt_storage.dart';

class UserController {
  final UserApi _userApi = UserApi();

  Future<User> getCurrentUser() async {
    final email = await JwtStorage.getEmail();
    if (email == null) throw Exception("Email не знайдено в JwtStorage");

    return await _userApi.getUserByEmail(email);
  }

  Future<void> updateUser(User user) async {
    await _userApi.updateUser(user);

    User updatedUser = await getCurrentUser();

    if (updatedUser.name != null) {
      
      await JwtStorage.saveUsername(updatedUser.name!);
    }
    await JwtStorage.saveEmail(updatedUser.email);

    if (updatedUser.id != null) {
      await JwtStorage.saveUserId(updatedUser.id!);
    }
  }
}
