// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrintSettingsModelAdapter extends TypeAdapter<PrintSettingsModel> {
  @override
  final int typeId = 20;

  @override
  PrintSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintSettingsModel(
      shopName: fields[0] as String,
      shopAddress: fields[1] as String,
      shopMobile: fields[2] as String,
      shopEmail: fields[3] as String,
      gstin: fields[4] as String,
      templateId: fields[5] as int,
      paperSize: fields[6] as String,
      customBlocksOrder: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PrintSettingsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.shopName)
      ..writeByte(1)
      ..write(obj.shopAddress)
      ..writeByte(2)
      ..write(obj.shopMobile)
      ..writeByte(3)
      ..write(obj.shopEmail)
      ..writeByte(4)
      ..write(obj.gstin)
      ..writeByte(5)
      ..write(obj.templateId)
      ..writeByte(6)
      ..write(obj.paperSize)
      ..writeByte(7)
      ..write(obj.customBlocksOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
