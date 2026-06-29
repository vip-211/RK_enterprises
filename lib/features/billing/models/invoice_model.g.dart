// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceItemModelAdapter extends TypeAdapter<InvoiceItemModel> {
  @override
  final int typeId = 4;

  @override
  InvoiceItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItemModel(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as double,
      unitPrice: fields[3] as double,
      discountAmount: fields[4] as double,
      gstPercentage: fields[5] as double,
      gstAmount: fields[6] as double,
      totalAmount: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.discountAmount)
      ..writeByte(5)
      ..write(obj.gstPercentage)
      ..writeByte(6)
      ..write(obj.gstAmount)
      ..writeByte(7)
      ..write(obj.totalAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 5;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      invoiceDate: fields[2] as DateTime,
      customerId: fields[3] as String?,
      customerName: fields[4] as String?,
      items: (fields[5] as List).cast<InvoiceItemModel>(),
      subTotal: fields[6] as double,
      totalDiscount: fields[7] as double,
      totalGst: fields[8] as double,
      roundOff: fields[9] as double,
      grandTotal: fields[10] as double,
      paymentMethod: fields[11] as String,
      amountPaid: fields[12] as double,
      notes: fields[13] as String?,
      isSynced: fields[14] as bool,
      operation: fields[15] as String,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
      deletedAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.invoiceDate)
      ..writeByte(3)
      ..write(obj.customerId)
      ..writeByte(4)
      ..write(obj.customerName)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.subTotal)
      ..writeByte(7)
      ..write(obj.totalDiscount)
      ..writeByte(8)
      ..write(obj.totalGst)
      ..writeByte(9)
      ..write(obj.roundOff)
      ..writeByte(10)
      ..write(obj.grandTotal)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.amountPaid)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.isSynced)
      ..writeByte(15)
      ..write(obj.operation)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
