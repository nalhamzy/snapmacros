import 'dart:convert';

import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snapmacros/core/models/meal.dart';
import 'package:snapmacros/core/models/user_profile.dart';

import 'fake_images.dart';

Future<void> seedDemoState() async {
  final img1 = await writeDemoMealImage(
    filename: 'breakfast.png',
    palette: const [
      Color(0xFF00D980),
      Color(0xFF5C9BFF),
      Color(0xFFFF5C8A),
      Color(0xFFFFC85C),
      Color(0xFF8B5CFF),
    ],
  );
  final img2 = await writeDemoMealImage(
    filename: 'lunch.png',
    palette: const [
      Color(0xFF5C9BFF),
      Color(0xFF00D980),
      Color(0xFFFFC85C),
      Color(0xFF8B5CFF),
      Color(0xFFFF5C8A),
    ],
  );
  final img3 = await writeDemoMealImage(
    filename: 'dinner.png',
    palette: const [
      Color(0xFF8B5CFF),
      Color(0xFFFF5C8A),
      Color(0xFF00D980),
      Color(0xFF5C9BFF),
      Color(0xFFFFC85C),
    ],
  );

  const profile = UserProfile(
    onboarded: true,
    sex: Sex.male,
    age: 27,
    heightCm: 180,
    weightKg: 78,
    activity: Activity.moderate,
    goal: Goal.recomp,
    calorieTarget: 2450,
    proteinTarget: 170,
    carbsTarget: 260,
    fatTarget: 78,
    proTier: ProTier.none,
    scanTokens: 3,
    streakDays: 12,
    lastLogDate: '2026-04-17',
  );

  final today = DateTime(2026, 4, 17);
  DateTime at(DateTime d, int h, int m) =>
      DateTime(d.year, d.month, d.day, h, m);

  final meals = <Meal>[
    // Today's meals (populate HomeScreen)
    Meal(
      id: 't1',
      imagePath: img1,
      type: MealType.breakfast,
      timestamp: at(today, 8, 20),
      items: const [
        MealItem(
          name: 'Greek yogurt (0% fat)',
          grams: 200,
          macros: Macros(calories: 118, protein: 20, carbs: 7.2, fat: 0.8),
        ),
        MealItem(
          name: 'Berries (mixed)',
          grams: 100,
          macros: Macros(calories: 57, protein: 0.7, carbs: 14, fat: 0.3),
        ),
        MealItem(
          name: 'Oats (dry)',
          grams: 50,
          macros: Macros(calories: 195, protein: 8.5, carbs: 33, fat: 3.5),
        ),
      ],
      source: 'gemini',
      confidence: 0.88,
    ),
    Meal(
      id: 't2',
      imagePath: img2,
      type: MealType.lunch,
      timestamp: at(today, 13, 5),
      items: const [
        MealItem(
          name: 'Chicken breast (grilled)',
          grams: 180,
          macros: Macros(calories: 297, protein: 55.8, carbs: 0, fat: 6.5),
        ),
        MealItem(
          name: 'White rice (cooked)',
          grams: 200,
          macros: Macros(calories: 260, protein: 5.4, carbs: 56, fat: 0.6),
        ),
        MealItem(
          name: 'Broccoli',
          grams: 100,
          macros: Macros(calories: 34, protein: 2.8, carbs: 7, fat: 0.4),
        ),
      ],
      source: 'gemini',
      confidence: 0.92,
    ),
    Meal(
      id: 't3',
      imagePath: img3,
      type: MealType.dinner,
      timestamp: at(today, 19, 40),
      items: const [
        MealItem(
          name: 'Salmon (cooked)',
          grams: 150,
          macros: Macros(calories: 309, protein: 33, carbs: 0, fat: 19.5),
        ),
        MealItem(
          name: 'Sweet potato (baked)',
          grams: 200,
          macros: Macros(calories: 180, protein: 4, carbs: 42, fat: 0.2),
        ),
        MealItem(
          name: 'Mixed salad',
          grams: 120,
          macros: Macros(calories: 24, protein: 1.8, carbs: 3.6, fat: 0.4),
        ),
      ],
      source: 'gemini',
      confidence: 0.85,
    ),
    // Previous 6 days — for the 7-day trend chart
    for (int daysAgo = 1; daysAgo <= 6; daysAgo++)
      Meal(
        id: 'day$daysAgo',
        type: MealType.dinner,
        timestamp: today.subtract(Duration(days: daysAgo)),
        items: [
          MealItem(
            name: 'Daily summary',
            grams: 100,
            macros: Macros(
              calories: 2100 + (daysAgo * 60) + (daysAgo.isEven ? 120 : -80),
              protein: 150 + daysAgo * 2,
              carbs: 220 + daysAgo * 3,
              fat: (70 + daysAgo).toDouble(),
            ),
          ),
        ],
        source: 'manual',
      ),
  ];

  SharedPreferences.setMockInitialValues({
    'snap.profile.v1': jsonEncode(profile.toJson()),
    'snap.meals.v1': jsonEncode(meals.map((m) => m.toJson()).toList()),
  });
}
