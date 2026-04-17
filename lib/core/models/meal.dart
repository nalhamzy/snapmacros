import 'package:equatable/equatable.dart';

enum MealType { breakfast, lunch, dinner, snack }

MealType mealTypeFromHour(int hour) {
  if (hour < 10) return MealType.breakfast;
  if (hour < 15) return MealType.lunch;
  if (hour < 20) return MealType.dinner;
  return MealType.snack;
}

class Macros extends Equatable {
  final double calories;
  final double protein;   // grams
  final double carbs;
  final double fat;

  const Macros({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  Macros operator +(Macros o) => Macros(
        calories: calories + o.calories,
        protein: protein + o.protein,
        carbs: carbs + o.carbs,
        fat: fat + o.fat,
      );

  Macros scale(double factor) => Macros(
        calories: calories * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fat: fat * factor,
      );

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory Macros.fromJson(Map<String, dynamic> j) => Macros(
        calories: (j['calories'] as num?)?.toDouble() ?? 0,
        protein: (j['protein'] as num?)?.toDouble() ?? 0,
        carbs: (j['carbs'] as num?)?.toDouble() ?? 0,
        fat: (j['fat'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [calories, protein, carbs, fat];
}

class MealItem extends Equatable {
  final String name;
  final double grams;
  final Macros macros;
  const MealItem({
    required this.name,
    required this.grams,
    required this.macros,
  });

  MealItem copyWith({String? name, double? grams, Macros? macros}) =>
      MealItem(name: name ?? this.name, grams: grams ?? this.grams, macros: macros ?? this.macros);

  Map<String, dynamic> toJson() =>
      {'name': name, 'grams': grams, 'macros': macros.toJson()};

  factory MealItem.fromJson(Map<String, dynamic> j) => MealItem(
        name: j['name'] as String,
        grams: (j['grams'] as num).toDouble(),
        macros: Macros.fromJson(j['macros'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [name, grams, macros];
}

class Meal extends Equatable {
  final String id;
  final String? imagePath;
  final MealType type;
  final DateTime timestamp;
  final List<MealItem> items;
  final String source;     // "ai", "manual", "search"
  final double confidence; // 0..1

  const Meal({
    required this.id,
    this.imagePath,
    required this.type,
    required this.timestamp,
    required this.items,
    required this.source,
    this.confidence = 0.8,
  });

  Macros get total =>
      items.fold(const Macros(), (acc, i) => acc + i.macros);

  Meal copyWith({
    String? imagePath,
    MealType? type,
    List<MealItem>? items,
    String? source,
    double? confidence,
  }) =>
      Meal(
        id: id,
        imagePath: imagePath ?? this.imagePath,
        type: type ?? this.type,
        timestamp: timestamp,
        items: items ?? this.items,
        source: source ?? this.source,
        confidence: confidence ?? this.confidence,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'source': source,
        'confidence': confidence,
      };

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        id: j['id'] as String,
        imagePath: j['imagePath'] as String?,
        type: MealType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => MealType.snack,
        ),
        timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ??
            DateTime.now(),
        items: (j['items'] as List<dynamic>)
            .map((e) => MealItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: j['source'] as String? ?? 'manual',
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0.8,
      );

  @override
  List<Object?> get props =>
      [id, imagePath, type, timestamp, items, source, confidence];
}
