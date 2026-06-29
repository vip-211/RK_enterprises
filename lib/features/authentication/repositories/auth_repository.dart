import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/core/utils/password_utils.dart';

class AuthRepository {
  final Box<UserModel> _userBox = Hive.box<UserModel>(HiveBoxes.users);

  Future<UserModel?> login(String email, String password) async {
    // If no user exists, create a default owner account
    if (_userBox.isEmpty) {
      final owner = UserModel(
        id: const Uuid().v4(),
        name: 'Super Admin',
        email: 'owner@rk.com',
        phone: '1234567890',
        role: 'Admin',
        password: PasswordUtils.hashPassword('admin'), // Default password
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userBox.put(owner.id, owner);
      
      if (email == 'owner@rk.com' && password == 'admin') return owner;
      return null;
    }
    
    // Find first user with matching email/phone and password
    try {
      final hashedPassword = PasswordUtils.hashPassword(password);
      return _userBox.values.firstWhere((user) => 
        (user.email == email || user.phone == email) && user.password == hashedPassword
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> logout() async {
    // Implement logout logic, clear session
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StateProvider<UserModel?>((ref) => null);
