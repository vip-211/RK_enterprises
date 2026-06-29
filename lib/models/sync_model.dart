abstract class SyncModel {
  String get id;
  bool get isSynced;
  String get operation; // 'insert', 'update', 'delete'
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  
  Map<String, dynamic> toMap();
}

class SyncOperation {
  static const String insert = 'insert';
  static const String update = 'update';
  static const String delete = 'delete';
}
