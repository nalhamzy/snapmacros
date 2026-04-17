import '../models/meal.dart';

/// Minimal common-foods nutrition table (per 100 g).
/// Production versions can swap in USDA FoodData Central or Open Food Facts.
class NutritionEntry {
  final String name;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double defaultServingG;
  const NutritionEntry({
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.defaultServingG,
  });

  Macros macrosFor(double grams) {
    final f = grams / 100.0;
    return Macros(
      calories: caloriesPer100g * f,
      protein: proteinPer100g * f,
      carbs: carbsPer100g * f,
      fat: fatPer100g * f,
    );
  }
}

class NutritionDb {
  static const entries = <NutritionEntry>[
    NutritionEntry(name: 'Chicken breast (grilled)', category: 'Protein', caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, defaultServingG: 150),
    NutritionEntry(name: 'Ground beef (85/15)', category: 'Protein', caloriesPer100g: 250, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 17, defaultServingG: 120),
    NutritionEntry(name: 'Salmon (cooked)', category: 'Protein', caloriesPer100g: 206, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 13, defaultServingG: 140),
    NutritionEntry(name: 'Whole egg', category: 'Protein', caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, defaultServingG: 50),
    NutritionEntry(name: 'Egg white', category: 'Protein', caloriesPer100g: 52, proteinPer100g: 11, carbsPer100g: 0.7, fatPer100g: 0.2, defaultServingG: 33),
    NutritionEntry(name: 'Greek yogurt (0% fat)', category: 'Protein', caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4, defaultServingG: 170),
    NutritionEntry(name: 'Cottage cheese (2%)', category: 'Protein', caloriesPer100g: 84, proteinPer100g: 11, carbsPer100g: 3.4, fatPer100g: 2.3, defaultServingG: 120),
    NutritionEntry(name: 'Tuna (canned in water)', category: 'Protein', caloriesPer100g: 116, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 0.8, defaultServingG: 100),
    NutritionEntry(name: 'Tofu (firm)', category: 'Protein', caloriesPer100g: 144, proteinPer100g: 17, carbsPer100g: 2.8, fatPer100g: 8.7, defaultServingG: 150),
    NutritionEntry(name: 'Whey protein (1 scoop)', category: 'Protein', caloriesPer100g: 400, proteinPer100g: 80, carbsPer100g: 8, fatPer100g: 5, defaultServingG: 30),

    NutritionEntry(name: 'White rice (cooked)', category: 'Carbs', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, defaultServingG: 180),
    NutritionEntry(name: 'Brown rice (cooked)', category: 'Carbs', caloriesPer100g: 123, proteinPer100g: 2.7, carbsPer100g: 26, fatPer100g: 1, defaultServingG: 180),
    NutritionEntry(name: 'Pasta (cooked)', category: 'Carbs', caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 1.1, defaultServingG: 200),
    NutritionEntry(name: 'Bread (whole wheat)', category: 'Carbs', caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 4, defaultServingG: 40),
    NutritionEntry(name: 'Oats (dry)', category: 'Carbs', caloriesPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatPer100g: 7, defaultServingG: 50),
    NutritionEntry(name: 'Potato (baked)', category: 'Carbs', caloriesPer100g: 93, proteinPer100g: 2.5, carbsPer100g: 21, fatPer100g: 0.1, defaultServingG: 200),
    NutritionEntry(name: 'Sweet potato (baked)', category: 'Carbs', caloriesPer100g: 90, proteinPer100g: 2, carbsPer100g: 21, fatPer100g: 0.1, defaultServingG: 180),
    NutritionEntry(name: 'Quinoa (cooked)', category: 'Carbs', caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 21, fatPer100g: 1.9, defaultServingG: 150),

    NutritionEntry(name: 'Broccoli', category: 'Veg', caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 7, fatPer100g: 0.4, defaultServingG: 100),
    NutritionEntry(name: 'Spinach', category: 'Veg', caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, defaultServingG: 80),
    NutritionEntry(name: 'Mixed salad', category: 'Veg', caloriesPer100g: 20, proteinPer100g: 1.5, carbsPer100g: 3, fatPer100g: 0.3, defaultServingG: 100),
    NutritionEntry(name: 'Avocado', category: 'Fat', caloriesPer100g: 160, proteinPer100g: 2, carbsPer100g: 9, fatPer100g: 15, defaultServingG: 70),

    NutritionEntry(name: 'Olive oil (1 tbsp)', category: 'Fat', caloriesPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, defaultServingG: 13),
    NutritionEntry(name: 'Peanut butter', category: 'Fat', caloriesPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatPer100g: 50, defaultServingG: 32),
    NutritionEntry(name: 'Almonds', category: 'Fat', caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, defaultServingG: 28),
    NutritionEntry(name: 'Cheddar cheese', category: 'Fat', caloriesPer100g: 403, proteinPer100g: 25, carbsPer100g: 1.3, fatPer100g: 33, defaultServingG: 40),

    NutritionEntry(name: 'Apple', category: 'Fruit', caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, defaultServingG: 150),
    NutritionEntry(name: 'Banana', category: 'Fruit', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, defaultServingG: 120),
    NutritionEntry(name: 'Berries (mixed)', category: 'Fruit', caloriesPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14, fatPer100g: 0.3, defaultServingG: 100),
    NutritionEntry(name: 'Orange', category: 'Fruit', caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.1, defaultServingG: 150),

    NutritionEntry(name: 'Milk (2%)', category: 'Dairy', caloriesPer100g: 50, proteinPer100g: 3.3, carbsPer100g: 4.8, fatPer100g: 2, defaultServingG: 240),
    NutritionEntry(name: 'Olive oil 1 tsp', category: 'Fat', caloriesPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, defaultServingG: 4),

    NutritionEntry(name: 'Cheeseburger (fast-food)', category: 'Meal', caloriesPer100g: 260, proteinPer100g: 14, carbsPer100g: 28, fatPer100g: 12, defaultServingG: 180),
    NutritionEntry(name: 'Cheese pizza slice', category: 'Meal', caloriesPer100g: 266, proteinPer100g: 11, carbsPer100g: 33, fatPer100g: 10, defaultServingG: 107),
    NutritionEntry(name: 'French fries', category: 'Meal', caloriesPer100g: 312, proteinPer100g: 3.4, carbsPer100g: 41, fatPer100g: 15, defaultServingG: 115),
    NutritionEntry(name: 'Burrito (chicken)', category: 'Meal', caloriesPer100g: 195, proteinPer100g: 12, carbsPer100g: 22, fatPer100g: 7, defaultServingG: 400),
    NutritionEntry(name: 'Sushi roll (6pc)', category: 'Meal', caloriesPer100g: 150, proteinPer100g: 6, carbsPer100g: 28, fatPer100g: 2, defaultServingG: 170),
    NutritionEntry(name: 'Caesar salad w/ chicken', category: 'Meal', caloriesPer100g: 170, proteinPer100g: 13, carbsPer100g: 6, fatPer100g: 11, defaultServingG: 300),
  ];

  static List<NutritionEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries
        .where((e) => e.name.toLowerCase().contains(q))
        .toList();
  }

  static NutritionEntry? fuzzyFind(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return null;
    for (final e in entries) {
      if (e.name.toLowerCase() == n) return e;
    }
    for (final e in entries) {
      if (e.name.toLowerCase().contains(n) ||
          n.contains(e.name.toLowerCase().split(' ').first)) {
        return e;
      }
    }
    return null;
  }
}
