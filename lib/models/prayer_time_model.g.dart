// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_time_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimeAdapter extends TypeAdapter<PrayerTime> {
  @override
  final int typeId = 1;

  @override
  PrayerTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTime(
      name: fields[0] as String,
      time: fields[1] as String,
      timezone: fields[2] as String,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTime obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.timezone)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomTimezoneAdapter extends TypeAdapter<CustomTimezone> {
  @override
  final int typeId = 2;

  @override
  CustomTimezone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomTimezone(
      id: fields[0] as String,
      name: fields[1] as String,
      timezone: fields[2] as String,
      createdAt: fields[3] as DateTime,
      userId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomTimezone obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.timezone)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomTimezoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
