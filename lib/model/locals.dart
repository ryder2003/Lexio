// locals.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Keys
  static const String _lessonsKey = 'user_lessons_list';
  static const String _adhdImagePrefix = 'adhd_image_';
  static const int _cacheValidityDays = 7;

  // Lesson Management ---------------------------------------------------------
  static Future<void> saveLessonDetails({
    required String title,
    required String subject,
    required String uploadResponse,
    required String filePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final newLesson = {
      'title': title,
      'subject': subject,
      'uploadResponse': uploadResponse,
      'filePath': filePath,
      'createdAt': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final existingLessons = await getLessonList();
    existingLessons.add(newLesson);
    await prefs.setString(_lessonsKey, jsonEncode(existingLessons));
  }

  static Future<List<Map<String, dynamic>>> getLessonList() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsData = prefs.getString(_lessonsKey);
    if (lessonsData != null) {
      final List<dynamic> decoded = jsonDecode(lessonsData);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> clearAllLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lessonsKey);
  }

  // ADHD Image Caching --------------------------------------------------------
  static Future<void> cacheAdhdImage({
    required String lessonContent,
    required String imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateAdhdKey(lessonContent);
    await prefs.setString(key, imageUrl);
    await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getCachedAdhdImage(String lessonContent) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateAdhdKey(lessonContent);
    final timestamp = prefs.getInt('${key}_ts');

    if (timestamp != null && _isCacheValid(timestamp)) {
      return prefs.getString(key);
    }

    // Auto-clear expired cache
    await prefs.remove(key);
    await prefs.remove('${key}_ts');
    return null;
  }

  static Future<void> clearAdhdCache({String? lessonContent}) async {
    final prefs = await SharedPreferences.getInstance();
    if (lessonContent != null) {
      final key = _generateAdhdKey(lessonContent);
      await prefs.remove(key);
      await prefs.remove('${key}_ts');
    } else {
      final keys = prefs.getKeys().where((k) => k.startsWith(_adhdImagePrefix));
      for (final key in keys) {
        await prefs.remove(key);
        await prefs.remove('${key}_ts');
      }
    }
  }

  // Shared Helper Methods -----------------------------------------------------
  static String _generateAdhdKey(String content) {
    return '${_adhdImagePrefix}${content.hashCode}';
  }

  static bool _isCacheValid(int timestamp) {
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expirationDate = cacheDate.add(const Duration(days: _cacheValidityDays));
    return DateTime.now().isBefore(expirationDate);
  }

  // General Utilities ---------------------------------------------------------
  static Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }
}