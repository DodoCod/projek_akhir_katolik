import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek_akhir_katolik/utils/constants.dart';

/// Model data untuk menyimpan informasi Timezone real-time dari World Time API.
class TimezoneInfo {
  final String timezone;
  final String abbreviation;
  final DateTime datetime;
  final int utcOffset; // Offset dalam detik
  final String utcOffsetString; // Format: "+07:00"
  final DateTime fetchedAt; 

  TimezoneInfo({
    required this.timezone,
    required this.abbreviation,
    required this.datetime,
    required this.utcOffset,
    required this.utcOffsetString,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  /// Membuat instance TimezoneInfo dari Map (JSON).
  factory TimezoneInfo.fromJson(Map<String, dynamic> json) {
    final rawOffset = json['raw_offset'] ?? 0;
    final dstOffset = json['dst_offset'] ?? 0;
    final isDst = json['dst'] ?? false;
    
    return TimezoneInfo(
      timezone: json['timezone'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      datetime: DateTime.parse(json['datetime']),
      utcOffset: rawOffset + (isDst ? dstOffset : 0), 
      utcOffsetString: json['utc_offset'] ?? '+00:00',
    );
  }

  /// Membuat salinan objek dengan tanggal/waktu baru (digunakan untuk clock ticker).
  TimezoneInfo copyWithDateTime(DateTime newDateTime) {
    return TimezoneInfo(
      timezone: timezone,
      abbreviation: abbreviation,
      datetime: newDateTime,
      utcOffset: utcOffset,
      utcOffsetString: utcOffsetString,
      fetchedAt: fetchedAt,
    );
  }
}
class WorldTimeService {
  static final Map<String, TimezoneInfo> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Mengambil info waktu real-time dan offset dari World Time API.
  static Future<TimezoneInfo?> getTimezoneInfo(String timezone) async {
    // Cek cache dulu
    if (_cache.containsKey(timezone)) {
      final cached = _cache[timezone]!;
      if (DateTime.now().difference(cached.fetchedAt) < _cacheDuration) {
        // Koreksi waktu cached dengan waktu UTC saat ini
        return cached.copyWithDateTime(DateTime.now().toUtc().add(Duration(seconds: cached.utcOffset)));
      }
    }

    try {
      final url = '${ApiConstants.timezoneBaseUrl}/$timezone'; 
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final info = TimezoneInfo.fromJson(data);
        _cache[timezone] = info;
        return info;
      } else {
        _cache.remove(timezone); // Hapus cache jika API error
        return null;
      }
    } catch (e) {
      _cache.remove(timezone); // HAPUS CACHE JIKA KONEKSI GAGAL
      return null;
    }
  }

  // Mengambil info waktu untuk beberapa zona sekaligus.
  static Future<Map<String, TimezoneInfo?>> getMultipleTimezones(
    List<String> timezones,
  ) async {
    final Map<String, TimezoneInfo?> result = {};
    for (final timezone in timezones) {
      result[timezone] = await getTimezoneInfo(timezone);
    }
    // logika fallback untuk Jakarta dan Vatikan jika fetch API gagal
    if (result['Asia/Jakarta'] == null) {
      result['Asia/Jakarta'] = _getFallbackTimezoneInfo('Asia/Jakarta');
    }
    if (result[ApiConstants.vaticanTimezone] == null) {
      result[ApiConstants.vaticanTimezone] = _getFallbackTimezoneInfo(ApiConstants.vaticanTimezone);
    }
    return result;
  }

  static Future<DateTime?> convertTimeWithAPI({
    required DateTime sourceDateTime,
    required String sourceZone,
    required String targetZone,
  }) async {
    try {
      final sourceInfo = await getTimezoneInfo(sourceZone);
      final targetInfo = await getTimezoneInfo(targetZone);

      if (sourceInfo == null || targetInfo == null) {
        return convertTime(sourceDateTime: sourceDateTime, sourceZone: sourceZone, targetZone: targetZone); 
      }

      // 1. Konversi ke UTC: (Waktu Sumber - Offset Sumber)
      final utcTime = sourceDateTime.subtract(
        Duration(seconds: sourceInfo.utcOffset),
      );

      // 2. Konversi ke Target: (UTC + Offset Target)
      final targetTime = utcTime.add(
        Duration(seconds: targetInfo.utcOffset),
      );

      return targetTime;
      
    } catch (e) {
      return convertTime(sourceDateTime: sourceDateTime, sourceZone: sourceZone, targetZone: targetZone);
    }
  }

  /// Konversi waktu secara sinkron menggunakan offset jam hardcoded (fallback).
  static DateTime convertTime({
    required DateTime sourceDateTime,
    required String sourceZone,
    required String targetZone,
  }) {
    final sourceOffset = _getTimezoneOffsetFallback(sourceZone);
    final targetOffset = _getTimezoneOffsetFallback(targetZone);

    final utcTime = sourceDateTime.subtract(Duration(hours: sourceOffset));
    final targetTime = utcTime.add(Duration(hours: targetOffset));

    return targetTime;
  }

  /// Dapatkan data TimezoneInfo dengan offset hardcoded untuk fallback.
  static TimezoneInfo _getFallbackTimezoneInfo(String timezone) {
    final offsetHours = _getTimezoneOffsetFallback(timezone);
    final offsetSeconds = offsetHours * 3600;
    
    return TimezoneInfo(
        timezone: timezone,
        abbreviation: timezone.split('/').last,
        datetime: DateTime.now().toUtc().add(Duration(seconds: offsetSeconds)),
        utcOffset: offsetSeconds,
        utcOffsetString: (offsetHours >= 0 ? '+' : '') + offsetHours.toString().padLeft(2, '0') + ':00',
    );
  }
  
  /// Mengambil daftar offset jam hardcoded untuk konversi fallback.
  static int _getTimezoneOffsetFallback(String timezone) {
    final offsets = {
      'Asia/Jakarta': 7, 'Asia/Makassar': 8, 'Asia/Jayapura': 9,
      'Europe/Vatican': 1, 'Europe/Rome': 1, 'Europe/London': 0,
      'Europe/Paris': 1, 'America/New_York': -5, 'America/Los_Angeles': -8,
      'America/Chicago': -6, 'Asia/Tokyo': 9, 'Asia/Singapore': 8,
      'Asia/Dubai': 4, 'Australia/Sydney': 10, 'Pacific/Auckland': 12,
      'Africa/Cairo': 2, 'Africa/Johannesburg': 2, 'Africa/Nairobi': 3,
    };
    return offsets[timezone] ?? 0;
  }

  /// Mengambil daftar identifier zona waktu yang didukung.
  static List<String> getAvailableTimezones() {
    return TimezoneList.kTimezoneIdentifiers;
  }

  /// Mengambil nama tampilan zona waktu dengan emoji.
  static String getTimezoneDisplayName(String timezone) {
    final names = {
      'Asia/Jakarta': '🇮🇩 Jakarta (WIB)', 'Asia/Makassar': '🇮🇩 Makassar (WITA)',
      'Asia/Jayapura': '🇮🇩 Jayapura (WIT)', 'Asia/Dubai': '🇦🇪 Dubai',
      'Asia/Hong_Kong': '🇭🇰 Hong Kong', 'Asia/Jerusalem': '🇮🇱 Jerusalem',
      'Asia/Kolkata': '🇮🇳 Kolkata', 'Asia/Manila': '🇵🇭 Manila',
      'Asia/Seoul': '🇰🇷 Seoul', 'Asia/Shanghai': '🇨🇳 Shanghai',
      'Asia/Singapore': '🇸🇬 Singapore', 'Asia/Tokyo': '🇯🇵 Tokyo',
      'Australia/Sydney': '🇦🇺 Sydney', 'Australia/Melbourne': '🇦🇺 Melbourne',
      'Europe/Amsterdam': '🇳🇱 Amsterdam', 'Europe/Berlin': '🇩🇪 Berlin',
      'Europe/Dublin': '🇮🇪 Dublin', 'Europe/London': '🇬🇧 London',
      'Europe/Moscow': '🇷🇺 Moscow', 'Europe/Paris': '🇫🇷 Paris',
      'Europe/Rome': '🇮🇹 Rome', 'Europe/Vatican': '🇻🇦 Vatican',
      'America/New_York': '🇺🇸 New York', 'America/Los_Angeles': '🇺🇸 Los Angeles',
      'America/Toronto': '🇨🇦 Toronto', 'America/Vancouver': '🇨🇦 Vancouver',
      'America/Sao_Paulo': '🇧🇷 São Paulo', 'America/Mexico_City': '🇲🇽 Mexico City',
      'Pacific/Auckland': '🇳🇿 Auckland', 'Pacific/Honolulu': '🇺🇸 Honolulu',
      'Africa/Cairo': '🇪🇬 Cairo', 'Africa/Johannesburg': '🇿🇦 Johannesburg',
      'Africa/Nairobi': '🇰🇪 Nairobi',
    };
    return names[timezone] ?? timezone.replaceAll('_', ' ').replaceFirst('/', ' - ');
  }

  /// Memformat DateTime menjadi string HH:mm.
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Memformat DateTime menjadi string HH:mm:ss.
  static String formatTimeWithSeconds(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Memeriksa apakah waktu berada di rentang Angelus (06:00, 12:00, 18:00).
  static bool isAngelusTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final angelusHours = [6, 12, 18];
    for (final angelusHour in angelusHours) {
      if (hour == angelusHour && minute >= 0 && minute <= 5) {
        return true;
      }
    }
    return false;
  }

  /// Menghapus cache offset waktu.
  static void clearCache() {
    _cache.clear();
  }
}