import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_katolik/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user_id';
  static const String _usernameKey = 'username';

  Box<User> get _usersBox => Hive.box<User>(_boxName);
  Box get _settingsBox => Hive.box('settings');

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<bool> _saveUsernameToPrefs(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await Future.delayed(const Duration(milliseconds: 100));
      
      final prefsVerify = await SharedPreferences.getInstance();
      final saved = prefsVerify.getString(_usernameKey);
      
      return saved == username;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUsernameFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUsernameToPrefs(String username) async {
    return await _saveUsernameToPrefs(username);
  }

  Future<void> clearUsernameFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
    } catch (e) {
      // Silent fail
    }
  }

  Future<bool> registerUser(
    String username,
    String password,
    File? profileImage,
  ) async {
    try {
      final existingUser = _usersBox.values.firstWhere(
        (user) => user.username == username,
        orElse: () => User(id: '', username: '', password: '', createdAt: DateTime.now()),
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
      await _settingsBox.put(_currentUserKey, userId);
      await _saveUsernameToPrefs(username);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      final user = _usersBox.values.firstWhere(
        (user) => user.username == username && user.password == hashedPassword,
        orElse: () => User(id: '', username: '', password: '', createdAt: DateTime.now()),
      );

      if (user.id.isEmpty) {
        return false;
      }

      await _settingsBox.put(_currentUserKey, user.id);
      await _saveUsernameToPrefs(username);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _settingsBox.delete(_currentUserKey);
      await clearUsernameFromPrefs();
    } catch (e) {
      // Silent fail
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final userId = _settingsBox.get(_currentUserKey);
      return userId != null && userId.toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getLoggedInUser() async {
    try {
      final userId = _settingsBox.get(_currentUserKey);
      if (userId == null) {
        return null;
      }
      return _usersBox.get(userId);
    } catch (e) {
      return null;
    }
  }

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

  Future<bool> updateUser(User user) async {
    try {
      await _usersBox.put(user.id, user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _usersBox.delete(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> initialize() async {
    await Hive.openBox<User>(_boxName);
    await Hive.openBox('settings');
  }
}