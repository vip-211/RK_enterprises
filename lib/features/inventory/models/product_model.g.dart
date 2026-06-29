// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 1;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String,
      name: fields[1] as String,
      sku: fields[2] as String,
      barcode: fields[3] as String?,
      purchasePrice: fields[4] as double,
      sellingPrice: fields[5] as double,
      mrp: fields[6] as double,
      gstPercentage: fields[7] as double,
      hsnCode: fields[8] as String,
      openingStock: fields[9] as double,
      currentStock: fields[10] as double,
      minimumStock: fields[11] as double,
      brand: fields[12] as String,
      category: fields[13] as String,
      unit: fields[14] as String,
      imageUrl: fields[15] as String?,
      isSynced: fields[16] as bool,
      operation: fields[17] as String,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
      deletedAt: fields[20] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sku)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.purchasePrice)
      ..writeByte(5)
      ..write(obj.sellingPrice)
      ..writeByte(6)
      ..write(obj.mrp)
      ..writeByte(7)
      ..write(obj.gstPercentage)
      ..writeByte(8)
      ..write(obj.hsnCode)
      ..writeByte(9)
      ..write(obj.openingStock)
      ..writeByte(10)
      ..write(obj.currentStock)
      ..writeByte(11)
      ..write(obj.minimumStock)
      ..writeByte(12)
      ..write(obj.brand)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.unit)
      ..writeByte(15)
      ..write(obj.imageUrl)
      ..writeByte(16)
      ..write(obj.isSynced)
      ..writeByte(17)
      ..write(obj.operation)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
