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
      final owner = UserModel(
        id: const Uuid().v4(),
        name: 'Shop Owner',
        email: 'owner@rk.com',
        phone: '1234567890',
        role: 'Admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final staff1 = UserModel(
        id: const Uuid().v4(),
        name: 'Ramesh (Cashier)',
        email: 'ramesh@rk.com',
        phone: '9876543210',
        role: 'Cashier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final staff2 = UserModel(
        id: const Uuid().v4(),
        name: 'Suresh (Cashier)',
        email: 'suresh@rk.com',
        phone: '9876543211',
        role: 'Cashier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final staff3 = UserModel(
        id: const Uuid().v4(),
        name: 'Mukesh (Cashier)',
        email: 'mukesh@rk.com',
        phone: '9876543212',
        role: 'Cashier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _userBox.put(owner.id, owner);
      await _userBox.put(staff1.id, staff1);
      await _userBox.put(staff2.id, staff2);
      await _userBox.put(staff3.id, staff3);
      
      if (email == 'owner@rk.com') return owner;
      if (email == 'ramesh@rk.com') return staff1;
      if (email == 'suresh@rk.com') return staff2;
      if (email == 'mukesh@rk.com') return staff3;
      return null;
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
