import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_katolik/models/user_model.dart';
import 'package:uuid/uuid.dart';

// Layanan utama untuk mengelola otentikasi pengguna dan status keanggotaan (Premium)
class AuthService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user_id';

  // Getter untuk Box penyimpanan data User.
  Box<User> get _usersBox => Hive.box<User>(_boxName);
  
  // Getter untuk Box penyimpanan pengaturan umum (misalnya ID user yang sedang login).
  Box get _settingsBox => Hive.box('settings');

  /// Fungsi internal untuk melakukan hashing pada password menggunakan algoritma SHA-256.
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Mendaftarkan pengguna baru ke sistem.
  Future<bool> registerUser(
    String username,
    String password,
    File? profileImage,
  ) async {
    try {
      // Cek apakah username sudah ada
      final existingUser = _usersBox.values.firstWhere(
        (user) => user.username == username,
        orElse: () => User(
          id: '',
          username: '',
          password: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existingUser.id.isNotEmpty) {
        return false;
      }

      final userId = const Uuid().v4();
      final hashedPassword = _hashPassword(password);

      final newUser = User(
        id: userId,
        username: username,
        password: hashedPassword,
        profileImagePath: profileImage?.path,
        createdAt: DateTime.now(),
        isPremium: false,
      );

      await _usersBox.put(userId, newUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Memproses login pengguna dengan memverifikasi kredensial.
  Future<bool> loginUser(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      // Cari user berdasarkan username dan password hash
      final user = _usersBox.values.firstWhere(
        (user) => user.username == username && user.password == hashedPassword,
        orElse: () => User(
          id: '',
          username: '',
          password: '',
          createdAt: DateTime.now(),
        ),
      );

      if (user.id.isEmpty) {
        return false;
      }

      // Simpan ID pengguna yang berhasil login
      await _settingsBox.put(_currentUserKey, user.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menghapus ID pengguna dari settings box, secara efektif melakukan logout.
  Future<void> logoutUser() async {
    try {
      await _settingsBox.delete(_currentUserKey);
    } catch (e) {
      return;
    }
  }

  /// Memeriksa apakah terdapat ID pengguna yang tersimpan (sesi login aktif).
  Future<bool> isLoggedIn() async {
    try {
      final userId = _settingsBox.get(_currentUserKey);
      return userId != null && userId.toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil objek User yang saat ini sedang login.
  Future<User?> getLoggedInUser() async {
    try {
      final userId = _settingsBox.get(_currentUserKey);
      if (userId == null) {
        return null;
      }

      // Ambil objek User berdasarkan ID yang tersimpan
      return _usersBox.get(userId);
    } catch (e) {
      return null;
    }
  }

  /// Mengubah status pengguna yang sedang login menjadi Premium.
  Future<bool> upgradeCurrentUserToPremium() async {
    try {
      final user = await getLoggedInUser();
      if (user == null) {
        return false;
      }

      final premiumUser = user.copyWith(
        isPremium: true,
      );

      await _usersBox.put(premiumUser.id, premiumUser);
      return true;

    } catch (e) {
      return false;
    }
  }

  /// Mengubah status Premium pengguna yang sedang login menjadi Gratis.
  Future<bool> downgradeCurrentUserFromPremium() async {
    try {
      final user = await getLoggedInUser();
      if (user == null) {
        return false;
      }

      final downgradedUser = user.copyWith(
        isPremium: false,
      );

      await _usersBox.put(downgradedUser.id, downgradedUser);
      return true;

    } catch (e) {
      return false;
    }
  }

  /// Memperbarui data objek User yang sudah ada di Hive.
  Future<bool> updateUser(User user) async {
    try {
      await _usersBox.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menghapus data pengguna secara permanen dari Hive.
  Future<bool> deleteUser(String userId) async {
    try {
      await _usersBox.delete(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Harus dipanggil di awal aplikasi (main()) untuk membuka semua Box Hive yang diperlukan.
  static Future<void> initialize() async {
    await Hive.openBox<User>(_boxName);
    await Hive.openBox('settings');
  }
}