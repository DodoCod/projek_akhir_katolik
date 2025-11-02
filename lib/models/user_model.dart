import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Merepresentasikan data pengguna aplikasi, disimpan secara lokal menggunakan Hive.
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  @HiveField(2)
  final String? profileImagePath;

  @HiveField(3)
  final String id;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isPremium;

  User({
    required this.username,
    required this.password,
    this.profileImagePath,
    required this.id,
    required this.createdAt,
    this.isPremium = false,
  });

  // Membuat instance User dari Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
    username: map['username'] ?? '',
    password: map['password'] ?? '',
    profileImagePath: map['profileImagePath'],
    id: map['id'] ?? '',
    createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()), 
    isPremium: map['isPremium'] ?? false,
    );
  }

  // Mengkonversi instance User menjadi Map
  Map<String, dynamic> toMap() {
    return {
    'username': username,
    'password': password,
    'profileImagePath': profileImagePath,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'isPremium': isPremium,
    };
  }

  User copyWith({
    String? username,
    String? password,
    String? profileImagePath,
    String? id,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return User(
    username: username ?? this.username,
    password: password ?? this.password,
    profileImagePath: profileImagePath ?? this.profileImagePath,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    isPremium: isPremium ?? this.isPremium,
    );
  }
    
  // Getter sederhana untuk memeriksa status premium
  bool get isPremiumActive {
    return isPremium; 
  }
  
  String get membershipTier {
    return isPremiumActive ? 'Premium' : 'Gratis';
  }
}