import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Merepresentasikan data pengguna aplikasi, disimpan secara lokal menggunakan Hive.
@HiveType(typeId: 0)
class User extends HiveObject {
  /// Nama pengguna (Username)
  @HiveField(0)
  final String username;

  /// Kata sandi (Password)
  @HiveField(1)
  final String password;

  /// Path lokasi file gambar profil (Opsional)
  @HiveField(2)
  final String? profileImagePath;

  /// ID unik pengguna
  @HiveField(3)
  final String id;

  /// Waktu akun dibuat
  @HiveField(4)
  final DateTime createdAt;

  /// Status keanggotaan premium
  @HiveField(5)
  final bool isPremium;

  /// Tanggal kadaluarsa keanggotaan premium (Opsional)
  @HiveField(6)
  final DateTime? premiumExpiry;

  User({
    required this.username,
    required this.password,
    this.profileImagePath,
    required this.id,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiry,
  });

  /// Membuat instance User dari Map (misalnya dari SharedPreferences atau API).
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      profileImagePath: map['profileImagePath'],
      id: map['id'] ?? '',
      // Parsing String ISO 8601 menjadi DateTime
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()), 
      isPremium: map['isPremium'] ?? false,
      // Memeriksa dan parsing tanggal kadaluarsa premium
      premiumExpiry: map['premiumExpiry'] != null 
          ? DateTime.parse(map['premiumExpiry'])
          : null,
    );
  }

  /// Mengkonversi instance User menjadi Map untuk penyimpanan atau pengiriman data.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'profileImagePath': profileImagePath,
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      // Mengkonversi DateTime ke String ISO 8601 (Jika tidak null)
      'premiumExpiry': premiumExpiry?.toIso8601String(),
    };
  }

  /// Membuat salinan (copy) dari objek User dengan properti yang diubah.
  User copyWith({
    String? username,
    String? password,
    String? profileImagePath,
    String? id,
    DateTime? createdAt,
    bool? isPremium,
    DateTime? premiumExpiry,
  }) {
    return User(
      username: username ?? this.username,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
    );
  }

  /// Getter untuk memeriksa apakah status premium saat ini AKTIF (belum kadaluarsa).
  bool get isPremiumActive {
    // 1. Harus memiliki flag isPremium TRUE
    if (!isPremium) return false;
    // 2. Harus memiliki tanggal kadaluarsa
    if (premiumExpiry == null) return false;
    // 3. Tanggal kadaluarsa harus LEBIH dari waktu saat ini
    return premiumExpiry!.isAfter(DateTime.now());
  }

  /// Getter untuk mendapatkan status keanggotaan dalam format String.
  String get membershipTier {
    return isPremiumActive ? 'Premium' : 'Gratis';
  }
}