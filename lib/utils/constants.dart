import 'package:flutter/material.dart';

// API URLs
class ApiConstants {
  // Bible API
  static const String bibleBaseUrl = 'http://beeble.vercel.app/api/v1';
  
  // Liturgy API
  static const String liturgyBaseUrl = 'http://calapi.inadiutorium.cz/api/v0/en/calendars/default';
  
  // Currency API
  static const String currencyApiKey = 'ecbc5e0baafc029ee663c03147cd5d41';
  static const String currencyBaseUrl = 'https://api.exchangerate.host/live';
  
  // Timezone API
  static const String timezoneBaseUrl = 'https://worldtimeapi.org/api/timezone';
  
  // Vatican Timezone
  static const String vaticanTimezone = 'Europe/Vatican';
}

class TimezoneList {
  /// Daftar zona waktu pilihan untuk fitur konverter (Premium)
  static const List<String> kTimezoneIdentifiers = [
    'Asia/Jakarta',
    'Asia/Makassar',
    'Asia/Jayapura',
    'Asia/Dubai',
    'Asia/Hong_Kong',
    'Asia/Jerusalem',
    'Asia/Kolkata',
    'Asia/Manila',
    'Asia/Seoul',
    'Asia/Shanghai',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Australia/Melbourne',
    'Europe/Amsterdam',
    'Europe/Berlin',
    'Europe/Dublin',
    'Europe/London',
    'Europe/Moscow',
    'Europe/Paris',
    'Europe/Rome',
    'Europe/Vatican',
    'America/New_York',
    'America/Los_Angeles',
    'America/Toronto',
    'America/Vancouver',
    'America/Sao_Paulo',
    'America/Mexico_City',
    'Pacific/Auckland',
    'Pacific/Honolulu',
    'Africa/Cairo',
    'Africa/Johannesburg',
    'Africa/Nairobi',
  ];
}

class DummyData {
  static const List<Map<String, dynamic>> churches = [
    {
      'name': 'Gereja Katedral Jakarta',
      'address': 'Jl. Katedral No.7B, Pasar Baru',
      'lat': -6.16823,
      'lng': 106.83226,
    },
    {
      'name': 'Gereja Santa Theresia, Menteng',
      'address': 'Jl. Gereja Theresia No.1, Gondangdia',
      'lat': -6.19472,
      'lng': 106.82527,
    },
    {
      'name': 'Gereja St. Perawan Maria Diangkat ke Surga',
      'address': 'Jl. I. J. Kasimo, Yogyakarta',
      'lat': -7.78858,
      'lng': 110.36486,
    },
    {
      'name': 'Gereja Hati Kudus Yesus, Pugeran',
      'address': 'Jl. Suryaden No.3, Yogyakarta',
      'lat': -7.81099,
      'lng': 110.36141,
    },
    {
      'name': 'Gereja Katedral St. Petrus, Bandung',
      'address': 'Jl. Merdeka No.14, Bandung',
      'lat': -6.91357,
      'lng': 107.60945,
    },
    {
      'name': 'Gereja Katedral St. Perawan Maria (Surabaya)',
      'address': 'Jl. Polisi Istimewa No. 49, Surabaya',
      'lat': -7.29170,
      'lng': 112.74239,
    },
    {
      'name': 'Gereja Katedral Santa Maria (Semarang)',
      'address': 'Jl. Dr. Sutomo No. 15, Semarang',
      'lat': -6.98595,
      'lng': 110.40798,
    },
    {
      'name': 'Gereja Katedral Santa Maria (Medan)',
      'address': 'Jl. Pemuda No. 1, Medan',
      'lat': 3.59013,
      'lng': 98.67389,
    },
    {
      'name': 'Gereja Katedral Hati Kudus Yesus (Makassar)',
      'address': 'Jl. Kajolalido No. 14, Makassar',
      'lat': -5.13840,
      'lng': 119.41400,
    },
    {
      'name': 'Gereja Kristus Raja (Kramat)',
      'address': 'Jl. Kramat Raya No. 114, Senen, Jakarta Pusat',
      'lat': -6.18349,
      'lng': 106.84277,
    },
    {
      'name': 'Gereja Katedral Roh Kudus (Denpasar)',
      'address': 'Jl. Tukad Musi No. 20, Denpasar',
      'lat': -8.67107,
      'lng': 115.22855,
    },
    {
      'name': 'Gereja Katedral Santa Maria (Palembang)',
      'address': 'Jl. Jenderal Sudirman No. 129, Palembang',
      'lat': -2.98188,
      'lng': 104.75704,
    },
    {
      'name': 'Gereja Katedral St. Yosef (Pontianak)',
      'address': 'Jl. Katedral No. 36, Pontianak',
      'lat': -0.02497,
      'lng': 109.34024,
    },
    {
      'name': 'Gereja Katedral Hati Tersuci Maria (Manado)',
      'address': 'Jl. Sam Ratulangi No. 14, Manado',
      'lat': 1.47460,
      'lng': 124.84232,
    },
    {
      'name': 'Gereja Katedral Kristus Raja (Jayapura)',
      'address': 'Jl. Kapt. P. Tendean, Dok V',
      'lat': -2.53420,
      'lng': 140.71610,
    },
    {
      'name': 'Gereja St. Antonius Padua, Kotabaru',
      'address': 'Jl. Abu Bakar Ali No. 25, Kotabaru, Yogyakarta',
      'lat': -7.78500,
      'lng': 110.37590,
    },
    {
      'name': 'Gereja Keluarga Kudus, Banteng',
      'address': 'Jl. Kaliurang Km. 8.7, Banteng, Sleman',
      'lat': -7.72890,
      'lng': 110.40740,
    },
    {
      'name': 'Gereja Kristus Raja, Baciro',
      'address': 'Jl. Permata, Baciro, Gondokusuman, Yogyakarta',
      'lat': -7.79250,
      'lng': 110.39520,
    },
    {
      'name': 'Gereja St. Yohanes Rasul, Pringwulung',
      'address': 'Jl. Raya Tajem, Pringwulung, Maguwoharjo',
      'lat': -7.76560,
      'lng': 110.41800,
    },
    {
      'name': 'Gereja St. Fransiskus Xaverius, Kidul Loji',
      'address': 'Jl. Sultan Agung No. 12, Gondomanan, Yogyakarta',
      'lat': -7.80010,
      'lng': 110.36670,
    },
  ];
}

// App Colors
class AppColors {
  // Primary Gradient
  static const Color gradientStart = Color(0xFF4A5568);
  static const Color gradientEnd = Color(0xFF2D3748);
  
  // Accent Colors
  static const Color purpleAccent = Color(0xFF667eea);
  static const Color purpleAccentDark = Color(0xFF764ba2);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static Color white = Colors.white;
  static Color white90 = Colors.white.withAlpha(229);
  static Color white80 = Colors.white.withAlpha(204);
  static Color white70 = Colors.white.withAlpha(179);
  static Color white60 = Colors.white.withAlpha(153);
  static Color white50 = Colors.white.withAlpha(128);
  static Color white40 = Colors.white.withAlpha(102);
  static Color white30 = Colors.white.withAlpha(77);
  static Color white20 = Colors.white.withAlpha(51);
  static Color white15 = Colors.white.withAlpha(38);
  static Color white10 = Colors.white.withAlpha(26);
  static Color white05 = Colors.white.withAlpha(13);

  // Red Colors
  static Color red90 = Colors.red.withAlpha(229);
  static Color red80 = Colors.red.withAlpha(204);
  static Color red70 = Colors.red.withAlpha(179);
  static Color red60 = Colors.red.withAlpha(153);
  static Color red50 = Colors.red.withAlpha(128);
  static Color red40 = Colors.red.withAlpha(102);
  static Color red30 = Colors.red.withAlpha(77);
  static Color red20 = Colors.red.withAlpha(51);
  static Color red15 = Colors.red.withAlpha(38);
  static Color red10 = Colors.red.withAlpha(26);
  static Color red05 = Colors.red.withAlpha(13);

  // Green Colors
  static Color green90 = Colors.green.withAlpha(229);
  static Color green80 = Colors.green.withAlpha(204);
  static Color green70 = Colors.green.withAlpha(179);
  static Color green60 = Colors.green.withAlpha(153);
  static Color green50 = Colors.green.withAlpha(128);
  static Color green40 = Colors.green.withAlpha(102);
  static Color green30 = Colors.green.withAlpha(77);
  static Color green20 = Colors.green.withAlpha(51);
  static Color green15 = Colors.green.withAlpha(38);
  static Color green10 = Colors.green.withAlpha(26);
  static Color green05 = Colors.green.withAlpha(13);
  
  // Amber Colors
  static Color amber90 = Colors.amber.withAlpha(229);
  static Color amber80 = Colors.amber.withAlpha(204);
  static Color amber70 = Colors.amber.withAlpha(179);
  static Color amber60 = Colors.amber.withAlpha(153);
  static Color amber50 = Colors.amber.withAlpha(128);
  static Color amber40 = Colors.amber.withAlpha(102);
  static Color amber30 = Colors.amber.withAlpha(77);
  static Color amber20 = Colors.amber.withAlpha(51);
  static Color amber15 = Colors.amber.withAlpha(38);
  static Color amber10 = Colors.amber.withAlpha(26);
  static Color amber05 = Colors.amber.withAlpha(13);
  
  // Liturgical Colors
  static const Color liturgyGreen = Color(0xFF10B981);
  static const Color liturgyRed = Color(0xFFDC2626);
  static const Color liturgyWhite = Colors.white;
  static const Color liturgyPurple = Color(0xFF9333EA);
  static const Color liturgyPink = Color(0xFFF9A8D4);
  static const Color liturgyBlack = Color(0xFF1F2937);
}

// App Dimensions
class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}

// App Strings
class AppStrings {
  static const String appName = 'Rohani Katolik';
  static const String appVersion = '1.0.0';
  
  // Navigation Labels
  static const String navHome = 'Beranda';
  static const String navBible = 'Alkitab';
  static const String navCalendar = 'Kalender';
  static const String navPrayer = 'Doa';
  static const String navProfile = 'Profil';
  
  // Auth
  static const String loginTitle = 'Selamat Datang';
  static const String loginSubtitle = 'Aplikasi Rohani Katolik';
  static const String registerTitle = 'Buat Akun Baru';
  
  // Angelus Times
  static const List<String> angelusTimes = ['06:00', '12:00', '18:00'];
  
  // Error Messages
  static const String errorNetwork = 'Gagal terhubung ke server. Cek koneksi internet Anda.';
  static const String errorGeneric = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorLogin = 'Login gagal. Cek username dan password.';
  static const String errorRegister = 'Registrasi gagal. Username mungkin sudah dipakai.';
}

// Notification IDs
class NotificationIds {
  static const int angelusMorning = 1;
  static const int angelusNoon = 2;
  static const int angelusEvening = 3;
}

// Database Keys
class DatabaseKeys {
  static const String users = 'users';
  static const String massSchedules = 'mass_schedules';
  static const String settings = 'settings';
  static const String currentUser = 'current_user';
}

// Membership Tiers
enum MembershipTier {
  free,
  premium,
}

class MembershipConfig {
  static const Map<MembershipTier, String> tierNames = {
    MembershipTier.free: 'Gratis',
    MembershipTier.premium: 'Premium',
  };
  
  static const Map<MembershipTier, List<String>> tierFeatures = {
    MembershipTier.free: [
      'Akses semua doa',
      'Baca Alkitab lengkap',
      'Kalender liturgi',
      'Notifikasi Angelus',
    ],
    MembershipTier.premium: [
      'Konversi waktu unlimited',
      'Konversi mata uang real-time',
      'Konversi waktu multi-zona',
    ],
  };
}