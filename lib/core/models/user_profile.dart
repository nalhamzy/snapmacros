import 'package:equatable/equatable.dart';

enum Sex { male, female }
enum Activity { sedentary, light, moderate, active, athlete }
enum Goal { lose, maintain, gain, recomp }
enum ProTier { none, weekly, monthly, yearly, lifetime }

class UserProfile extends Equatable {
  final bool onboarded;
  final Sex sex;
  final int age;
  final double heightCm;
  final double weightKg;
  final Activity activity;
  final Goal goal;
  final double calorieTarget;  // kcal
  final double proteinTarget;  // grams
  final double carbsTarget;
  final double fatTarget;
  final ProTier proTier;
  final int scanTokens;        // daily free photo scans remaining
  final String scanTokenDate;  // yyyy-MM-dd — reset daily
  final int streakDays;
  final String lastLogDate;

  const UserProfile({
    this.onboarded = false,
    this.sex = Sex.male,
    this.age = 25,
    this.heightCm = 175,
    this.weightKg = 75,
    this.activity = Activity.moderate,
    this.goal = Goal.maintain,
    this.calorieTarget = 2400,
    this.proteinTarget = 150,
    this.carbsTarget = 260,
    this.fatTarget = 80,
    this.proTier = ProTier.none,
    this.scanTokens = 3,
    this.scanTokenDate = '',
    this.streakDays = 0,
    this.lastLogDate = '',
  });

  bool get isPro => proTier != ProTier.none;

  UserProfile copyWith({
    bool? onboarded,
    Sex? sex,
    int? age,
    double? heightCm,
    double? weightKg,
    Activity? activity,
    Goal? goal,
    double? calorieTarget,
    double? proteinTarget,
    double? carbsTarget,
    double? fatTarget,
    ProTier? proTier,
    int? scanTokens,
    String? scanTokenDate,
    int? streakDays,
    String? lastLogDate,
  }) =>
      UserProfile(
        onboarded: onboarded ?? this.onboarded,
        sex: sex ?? this.sex,
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        activity: activity ?? this.activity,
        goal: goal ?? this.goal,
        calorieTarget: calorieTarget ?? this.calorieTarget,
        proteinTarget: proteinTarget ?? this.proteinTarget,
        carbsTarget: carbsTarget ?? this.carbsTarget,
        fatTarget: fatTarget ?? this.fatTarget,
        proTier: proTier ?? this.proTier,
        scanTokens: scanTokens ?? this.scanTokens,
        scanTokenDate: scanTokenDate ?? this.scanTokenDate,
        streakDays: streakDays ?? this.streakDays,
        lastLogDate: lastLogDate ?? this.lastLogDate,
      );

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'sex': sex.name,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activity': activity.name,
        'goal': goal.name,
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
        'proTier': proTier.name,
        'scanTokens': scanTokens,
        'scanTokenDate': scanTokenDate,
        'streakDays': streakDays,
        'lastLogDate': lastLogDate,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        onboarded: j['onboarded'] as bool? ?? false,
        sex: Sex.values.firstWhere(
            (s) => s.name == j['sex'], orElse: () => Sex.male),
        age: (j['age'] as num?)?.toInt() ?? 25,
        heightCm: (j['heightCm'] as num?)?.toDouble() ?? 175,
        weightKg: (j['weightKg'] as num?)?.toDouble() ?? 75,
        activity: Activity.values.firstWhere(
            (a) => a.name == j['activity'],
            orElse: () => Activity.moderate),
        goal: Goal.values.firstWhere(
            (g) => g.name == j['goal'],
            orElse: () => Goal.maintain),
        calorieTarget: (j['calorieTarget'] as num?)?.toDouble() ?? 2400,
        proteinTarget: (j['proteinTarget'] as num?)?.toDouble() ?? 150,
        carbsTarget: (j['carbsTarget'] as num?)?.toDouble() ?? 260,
        fatTarget: (j['fatTarget'] as num?)?.toDouble() ?? 80,
        proTier: ProTier.values.firstWhere(
            (p) => p.name == j['proTier'],
            orElse: () => ProTier.none),
        scanTokens: (j['scanTokens'] as num?)?.toInt() ?? 3,
        scanTokenDate: j['scanTokenDate'] as String? ?? '',
        streakDays: (j['streakDays'] as num?)?.toInt() ?? 0,
        lastLogDate: j['lastLogDate'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        onboarded, sex, age, heightCm, weightKg, activity, goal,
        calorieTarget, proteinTarget, carbsTarget, fatTarget,
        proTier, scanTokens, scanTokenDate, streakDays, lastLogDate,
      ];
}
