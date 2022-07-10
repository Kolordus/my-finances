// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PersistedPayment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersistedPaymentAdapter extends TypeAdapter<PersistedPayment> {
  @override
  final int typeId = 0;

  @override
  PersistedPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersistedPayment(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersistedPayment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentType)
      ..writeByte(4)
      ..write(obj.paymentMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
