import 'package:hive/hive.dart';

part 'prayer_time_model.g.dart'; 

@HiveType(typeId: 1)
class PrayerTime extends HiveObject {
  @HiveField(0)
  final String name; 
  @HiveField(1)
  final String time; 
  @HiveField(2)
  final String timezone;
  @HiveField(3)
  final DateTime date; 

  PrayerTime({
    required this.name,
    required this.time,
    required this.timezone,
    required this.date,
  });

  /// Getter untuk mengkonstruksi objek DateTime lengkap dari komponen tanggal dan waktu.
  DateTime get fullDateTime {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Menggabungkan tanggal (year, month, day) dari field 'date' dengan jam dan menit dari field 'time'
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
}

class TimezoneInfo {
  final String timezone;
  final String abbreviation;
  final DateTime datetime;
  final int utcOffset; // Offset UTC dalam detik
  final String utcOffsetString; 

  TimezoneInfo({
    required this.timezone,
    required this.abbreviation,
    required this.datetime,
    required this.utcOffset,
    required this.utcOffsetString,
  });

  /// Factory untuk mem-parsing JSON dari World Time API.
  factory TimezoneInfo.fromJson(Map<String, dynamic> json) {
    // Asumsi offset yang diterima API sudah benar
    return TimezoneInfo(
      timezone: json['timezone'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      datetime: DateTime.parse(json['datetime']),
      utcOffset: json['raw_offset'] ?? 0,
      utcOffsetString: json['utc_offset'] ?? '+00:00',
    );
  }
}

/// Model untuk menyimpan lokasi Timezone kustom yang dibuat oleh pengguna (fitur premium).
@HiveType(typeId: 2)
class CustomTimezone extends HiveObject {
  @HiveField(0)
  final String id; // ID unik untuk identifikasi

  @HiveField(1)
  final String name; // Nama custom (e.g., "Rumah Nenek")

  @HiveField(2)
  final String timezone; // Identifier Timezone IANA (e.g., "America/New_York")

  @HiveField(3)
  final DateTime createdAt; // Waktu pembuatan data

  @HiveField(4)
  final String userId; // ID user yang membuat entri ini

  CustomTimezone({
    required this.id,
    required this.name,
    required this.timezone,
    required this.createdAt,
    required this.userId,
  });
}