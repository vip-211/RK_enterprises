import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/staff/models/staff_model.dart';
import 'package:uuid/uuid.dart';
import 'package:rk_enterprises/sync/sync_manager.dart';

class StaffRepository {
  final Box<StaffModel> _box = Hive.box<StaffModel>(HiveBoxes.staff);

  List<StaffModel> getStaff() {
    return _box.values.where((s) => s.deletedAt == null).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<String> addStaff(StaffModel staff) async {
    final newStaff = StaffModel(
      id: const Uuid().v4(),
      name: staff.name,
      phone: staff.phone,
      role: staff.role,
      salary: staff.salary,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _box.put(newStaff.id, newStaff);
    SyncManager().syncAllPendingData();
    return newStaff.id;
  }

  Future<void> updateStaff(StaffModel staff) async {
    final updatedStaff = StaffModel(
      id: staff.id,
      name: staff.name,
      phone: staff.phone,
      role: staff.role,
      salary: staff.salary,
      isSynced: false,
      createdAt: staff.createdAt,
      updatedAt: DateTime.now(),
    );
    await _box.put(staff.id, updatedStaff);
    SyncManager().syncAllPendingData();
  }

  Future<void> deleteStaff(String id) async {
    final staff = _box.get(id);
    if (staff != null) {
      final deletedStaff = StaffModel(
        id: staff.id,
        name: staff.name,
        phone: staff.phone,
        role: staff.role,
        salary: staff.salary,
        isSynced: false,
        createdAt: staff.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: DateTime.now(),
      );
      await _box.put(id, deletedStaff);
      SyncManager().syncAllPendingData();
    }
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository();
});
