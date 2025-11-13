import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'db_helper.dart';

class AuthService {
  static const _keyUserId = 'current_user_id';

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final existing = await DBHelper.instance.getUserByUsername(username);
    if (existing != null) {
      return 'Ce nom d\'utilisateur existe déjà.';
    }

    final user = AppUser(username: username, email: email, password: password);

    try {
      await DBHelper.instance.insertUser(user.toMap());
      return null;
    } catch (e) {
      return 'Erreur inscription: ${e.toString()}';
    }
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final data = await DBHelper.instance.getUserByUsername(username);
    if (data == null) return 'Utilisateur introuvable';
    final user = AppUser.fromMap(data);
    if (user.password != password) return 'Mot de passe incorrect';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id!);
    return null;
  }

  Future<int?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
