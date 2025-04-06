// locals.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'adhd_image.dart';

class PreferencesHelper {
  // Keys
  static const String _lessonsKey = 'user_lessons_list';
  static const String _adhdImagePrefix = 'adhd_image_';
  static const int _cacheValidityDays = 7;

  // Lesson Management ---------------------------------------------------------
  static Future<void> saveLessonDetails({
    required String userId,
    required String title,
    required String subject,
    required String uploadResponse,
    required String filePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing lessons FOR THIS USER
    final existingLessons = await getLessonList(userId);

    final newLesson = {
      'userId': userId,
      'title': title,
      'subject': subject,
      'uploadResponse': uploadResponse,
      'filePath': filePath,
      'createdAt': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    existingLessons.add(newLesson);

    // Get ALL lessons from storage
    final allLessons = await _getAllLessons();

    // Remove existing entries for this user
    allLessons.removeWhere((lesson) => lesson['userId'] == userId);

    // Add updated list
    allLessons.addAll(existingLessons);

    await prefs.setString(_lessonsKey, jsonEncode(allLessons));
  }

  static Future<List<Map<String, dynamic>>> getLessonList(String userId) async {
    final allLessons = await _getAllLessons();
    return allLessons.where((lesson) => lesson['userId'] == userId).toList();
  }

  static Future<List<Map<String, dynamic>>> _getAllLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsData = prefs.getString(_lessonsKey);
    if (lessonsData != null) {
      final List<dynamic> decoded = jsonDecode(lessonsData);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> clearUserLessons(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final allLessons = await _getAllLessons();
    allLessons.removeWhere((lesson) => lesson['userId'] == userId);
    await prefs.setString(_lessonsKey, jsonEncode(allLessons));
  }

  // ADHD Image Caching --------------------------------------------------------
  static Future<void> cacheAdhdImage({
    required String lessonContent,
    required List<AdhdImage> images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateAdhdKey(lessonContent);
    final encodedData = jsonEncode(images.map((img) => img.toJson()).toList());
    await prefs.setString(key, encodedData);
    await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<AdhdImage>?> getCachedAdhdImage(String lessonContent) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateAdhdKey(lessonContent);
    final timestamp = prefs.getInt('${key}_ts');

    if (timestamp != null && _isCacheValid(timestamp)) {
      final cachedData = prefs.getString(key);
      if (cachedData != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData);
          return decoded.map((e) => AdhdImage.fromJson(e)).toList();
        } catch (e) {
          // Handle legacy format if needed
          return null;
        }
      }
    }

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
    return '$_adhdImagePrefix${content.hashCode}';
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

  static Future<void> migrateLegacyCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_adhdImagePrefix));

    for (final key in keys) {
      if (!key.endsWith('_ts')) {
        final value = prefs.getString(key);
        if (value != null) {
          // Check if it's old URL list format
          if (value.startsWith('[') && value.contains('http')) {
            try {
              final List<dynamic> urls = jsonDecode(value);
              final List<AdhdImage> images = urls.map((url) => AdhdImage(
                imageUrl: url.toString(),
                caption: "Visual Learning Aid",
              )).toList();

              await cacheAdhdImage(
                  lessonContent: key.replaceFirst(_adhdImagePrefix, ''),
                  images: images
              );
            } catch (e) {
              await prefs.remove(key);
            }
          }
        }
      }
    }
  }
}