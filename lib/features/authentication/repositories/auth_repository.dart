import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final Box<UserModel> _userBox = Hive.box<UserModel>(HiveBoxes.users);

  Future<UserModel?> login(String email, String password) async {
    // Mock login logic - in real app, call Firebase Auth then sync with Hive
    // For now, if no user exists, create a dummy one
    if (_userBox.isEmpty) {
      final dummyUser = UserModel(
        id: const Uuid().v4(),
        name: 'Admin User',
        email: email,
        phone: '1234567890',
        role: 'Super Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userBox.put(dummyUser.id, dummyUser);
      return dummyUser;
    }
    
    // Find first user with matching email
    try {
      return _userBox.values.firstWhere((user) => user.email == email);
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
