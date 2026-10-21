import "dart:convert";

import "package:flutter/services.dart" show rootBundle;
import "package:shared_preferences/shared_preferences.dart";

/// Loads the baked-in JSON data (from our websites) and owns every
/// piece of persistent state (shared_preferences). Everything is
/// offline and local — nothing leaves the device.
class DataStore {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ------------------------------------------------------------------
  // Baked web data
  // ------------------------------------------------------------------
  static Future<List<String>> loadStrings(String asset) async {
    try {
      final raw = await rootBundle.loadString("assets/data/$asset.json");
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<Map<String, dynamic>>> loadMaps(String asset) async {
    try {
      final raw = await rootBundle.loadString("assets/data/$asset.json");
      final list = jsonDecode(raw) as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  // ------------------------------------------------------------------
  // Generic prefs (per-feature keys, e.g. "countdown", "checklist")
  // ------------------------------------------------------------------
  static String getString(String key, [String fallback = ""]) =>
      _prefs?.getString(key) ?? fallback;

  static Future<void> setString(String key, String value) async =>
      _prefs?.setString(key, value);

  static bool getBool(String key, [bool fallback = false]) =>
      _prefs?.getBool(key) ?? fallback;

  static Future<void> setBool(String key, bool value) async =>
      _prefs?.setBool(key, value);

  static int getInt(String key, [int fallback = 0]) =>
      _prefs?.getInt(key) ?? fallback;

  static Future<void> setInt(String key, int value) async =>
      _prefs?.setInt(key, value);

  // ------------------------------------------------------------------
  // JSON blobs (lists/maps too big to store in typed fields)
  // ------------------------------------------------------------------
  static Map<String, dynamic> getJson(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> setJson(String key, Map<String, dynamic> value) =>
      setString(key, jsonEncode(value));

  static List<dynamic> getList(String key) {
    final raw = getString(key);
    if (raw.isEmpty) return const [];
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> setList(String key, List<dynamic> value) =>
      setString(key, jsonEncode(value));

  // ------------------------------------------------------------------
  // Theme persistence
  // ------------------------------------------------------------------
  /// null = follow system, true = dark, false = light.
  static bool? get darkMode {
    if (!(_prefs?.containsKey("uniroid.dark") ?? false)) return null;
    return getBool("uniroid.dark");
  }

  static Future<void> setDarkMode(bool? dark) async {
    if (dark == null) {
      await _prefs?.remove("uniroid.dark");
    } else {
      await setBool("uniroid.dark", dark);
    }
  }
}
