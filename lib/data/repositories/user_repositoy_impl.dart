import '../../domain/entities/loginResponse.dart';
import '../../domain/repositories/user_repository.dart';
import '../api/user_api.dart';
import '../../domain/entities/user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi userApi;

  UserRepositoryImpl(this.userApi);

  @override
  Future<LoginResponse?> login(String email, String password) async {
    return await userApi.login(email, password);
  }

  @override
  Future<bool> register(String name, String lastname, String email, String password) async {
    return await userApi.register(name, lastname, email, password);
  }

  @override
  Future<bool> editProfile(User user) async {
    return await userApi.editProfile(user);
  }

  @override
  Future<bool> changePassword(String newPassword) async{
    return await userApi.changePassword(newPassword);
  }
}