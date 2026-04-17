import '../models/user_profile.dart';

class MacroTargets {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  const MacroTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class TdeeCalculator {
  /// Mifflin-St Jeor BMR + activity multiplier + goal adjustment.
  static MacroTargets compute(UserProfile p) {
    final bmr = p.sex == Sex.male
        ? 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + 5
        : 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age - 161;

    final mult = switch (p.activity) {
      Activity.sedentary => 1.25,
      Activity.light => 1.40,
      Activity.moderate => 1.55,
      Activity.active => 1.725,
      Activity.athlete => 1.9,
    };

    double tdee = bmr * mult;

    // Goal adjustment (cleaner than hard 25% cuts; won't push 0 calorie zones).
    switch (p.goal) {
      case Goal.lose:
        tdee -= 500;
        break;
      case Goal.gain:
        tdee += 300;
        break;
      case Goal.maintain:
        break;
      case Goal.recomp:
        tdee -= 150;
        break;
    }
    if (tdee < 1200) tdee = 1200;

    // Macro split: protein by bodyweight, fat 25% of calories, carbs remainder.
    final proteinG = (p.weightKg * _proteinPerKg(p)).roundToDouble();
    final fatCal = tdee * 0.27;
    final fatG = (fatCal / 9).roundToDouble();
    final remainCal = tdee - proteinG * 4 - fatG * 9;
    final carbsG = (remainCal / 4).clamp(30, 1000).roundToDouble();

    return MacroTargets(
      calories: tdee.roundToDouble(),
      protein: proteinG,
      carbs: carbsG,
      fat: fatG,
    );
  }

  static double _proteinPerKg(UserProfile p) {
    switch (p.goal) {
      case Goal.lose:     return 2.2;
      case Goal.recomp:   return 2.0;
      case Goal.gain:     return 1.8;
      case Goal.maintain: return 1.6;
    }
  }
}
