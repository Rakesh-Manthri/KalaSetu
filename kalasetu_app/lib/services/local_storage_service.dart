import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class LocalStorageService {
  static const String _draftsBoxName = 'drafts';
  static const String _preferencesBoxName = 'preferences';
  static const String _localeKey = 'locale';

  late Box<dynamic> _draftsBox;
  late Box<dynamic> _preferencesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _draftsBox = await Hive.openBox<dynamic>(_draftsBoxName);
    _preferencesBox = await Hive.openBox<dynamic>(_preferencesBoxName);
  }

  Future<void> saveDraft(String id, Map<String, dynamic> data) async {
    await _draftsBox.put(id, data);
  }

  Map<String, dynamic>? getDraft(String id) {
    final data = _draftsBox.get(id);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  List<Map<String, dynamic>> getAllDrafts() {
    final List<Map<String, dynamic>> drafts = [];
    for (final key in _draftsBox.keys) {
      final data = _draftsBox.get(key);
      if (data is Map) {
        drafts.add(Map<String, dynamic>.from(data));
      }
    }
    return drafts;
  }

  Future<void> deleteDraft(String id) async {
    await _draftsBox.delete(id);
  }

  Future<void> savePreference(String key, dynamic value) async {
    await _preferencesBox.put(key, value);
  }

  T? getPreference<T>(String key) {
    return _preferencesBox.get(key) as T?;
  }

  String getLocale() {
    return getPreference<String>(_localeKey) ?? 'en';
  }

  Future<void> setLocale(String locale) async {
    await savePreference(_localeKey, locale);
  }
}
