import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/models/meal.dart';
import '../core/services/food_analyzer.dart';
import 'profile_provider.dart';
import 'storage_provider.dart';

class MealsState {
  final List<Meal> meals;
  final Meal? draft;          // unsaved meal from AI scan, awaiting confirm
  final bool analyzing;
  final String? note;
  final String? error;
  const MealsState({
    this.meals = const [],
    this.draft,
    this.analyzing = false,
    this.note,
    this.error,
  });

  MealsState copyWith({
    List<Meal>? meals,
    Meal? draft,
    bool? analyzing,
    String? note,
    String? error,
    bool clearDraft = false,
    bool clearError = false,
    bool clearNote = false,
  }) =>
      MealsState(
        meals: meals ?? this.meals,
        draft: clearDraft ? null : (draft ?? this.draft),
        analyzing: analyzing ?? this.analyzing,
        note: clearNote ? null : (note ?? this.note),
        error: clearError ? null : (error ?? this.error),
      );
}

class MealsNotifier extends Notifier<MealsState> {
  final _analyzer = FoodAnalyzer();

  @override
  MealsState build() {
    final storage = ref.read(storageServiceProvider);
    return MealsState(meals: storage.loadMeals());
  }

  void _persist() => ref.read(storageServiceProvider).saveMeals(state.meals);

  bool get hasRealAi => _analyzer.hasRealModel;

  Future<void> analyzePhoto(File photo) async {
    state = state.copyWith(analyzing: true, clearError: true, clearNote: true);
    try {
      final res = await _analyzer.analyzeImage(photo);

      // Copy the image to app-scoped storage.
      final dir = await getApplicationDocumentsDirectory();
      final mealsDir = Directory(p.join(dir.path, 'meals'));
      if (!await mealsDir.exists()) await mealsDir.create(recursive: true);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final targetPath = p.join(mealsDir.path, 'meal_$id.jpg');
      await photo.copy(targetPath);

      final now = DateTime.now();
      final draft = Meal(
        id: id,
        imagePath: targetPath,
        type: mealTypeFromHour(now.hour),
        timestamp: now,
        items: res.items.isEmpty
            ? [
                const MealItem(
                  name: 'Edit items →',
                  grams: 100,
                  macros: Macros(),
                )
              ]
            : res.items,
        source: res.source,
        confidence: res.confidence,
      );
      state = state.copyWith(
        analyzing: false,
        draft: draft,
        note: res.note,
      );
      await ref.read(profileProvider.notifier).consumeScanToken();
    } catch (e) {
      state = state.copyWith(
        analyzing: false,
        error: 'Couldn\'t analyze this photo: $e',
      );
    }
  }

  void startManualMeal({String? imagePath}) {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    state = state.copyWith(
      draft: Meal(
        id: id,
        imagePath: imagePath,
        type: mealTypeFromHour(now.hour),
        timestamp: now,
        items: const [],
        source: 'manual',
        confidence: 1.0,
      ),
    );
  }

  void updateDraft(Meal Function(Meal draft) edit) {
    final d = state.draft;
    if (d == null) return;
    state = state.copyWith(draft: edit(d));
  }

  Future<void> saveDraft() async {
    final d = state.draft;
    if (d == null) return;
    final meals = [d, ...state.meals].take(500).toList();
    state = state.copyWith(meals: meals, clearDraft: true);
    _persist();
    await ref.read(profileProvider.notifier).recordLogForStreak();
  }

  Future<void> addManual(Meal m) async {
    final meals = [m, ...state.meals].take(500).toList();
    state = state.copyWith(meals: meals);
    _persist();
    await ref.read(profileProvider.notifier).recordLogForStreak();
  }

  Future<void> deleteMeal(String id) async {
    final meals = state.meals.where((m) => m.id != id).toList();
    state = state.copyWith(meals: meals);
    _persist();
  }

  List<Meal> mealsOn(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return state.meals
        .where((m) => DateFormat('yyyy-MM-dd').format(m.timestamp) == key)
        .toList();
  }

  Macros totalOn(DateTime day) =>
      mealsOn(day).fold(const Macros(), (acc, m) => acc + m.total);

  void clearError() => state = state.copyWith(clearError: true);
  void clearDraft() => state = state.copyWith(clearDraft: true);
}

final mealsProvider =
    NotifierProvider<MealsNotifier, MealsState>(MealsNotifier.new);
