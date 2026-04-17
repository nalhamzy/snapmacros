import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../models/user_profile.dart';

class StorageService {
  static const _kProfile = 'snap.profile.v1';
  static const _kMeals = 'snap.meals.v1';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  UserProfile loadProfile() {
    final raw = _prefs.getString(_kProfile);
    if (raw == null || raw.isEmpty) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveProfile(UserProfile p) =>
      _prefs.setString(_kProfile, jsonEncode(p.toJson()));

  List<Meal> loadMeals() {
    final raw = _prefs.getString(_kMeals);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveMeals(List<Meal> meals) => _prefs.setString(
      _kMeals, jsonEncode(meals.map((m) => m.toJson()).toList()));
}
