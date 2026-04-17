import 'package:flutter_test/flutter_test.dart';
import 'package:snapmacros/core/models/meal.dart';
import 'package:snapmacros/core/models/user_profile.dart';
import 'package:snapmacros/core/services/tdee_calculator.dart';

void main() {
  test('TDEE calculator produces sensible macros for average male', () {
    const p = UserProfile(
      onboarded: true,
      sex: Sex.male,
      age: 28,
      heightCm: 180,
      weightKg: 80,
      activity: Activity.moderate,
      goal: Goal.maintain,
    );
    final t = TdeeCalculator.compute(p);
    expect(t.calories, inInclusiveRange(2300, 3000));
    expect(t.protein, inInclusiveRange(100, 200));
    expect(t.fat, greaterThan(50));
  });

  test('Macros add correctly', () {
    const a = Macros(calories: 300, protein: 30, carbs: 20, fat: 10);
    const b = Macros(calories: 400, protein: 40, carbs: 30, fat: 15);
    final c = a + b;
    expect(c.calories, 700);
    expect(c.protein, 70);
  });
}
