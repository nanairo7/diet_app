import 'package:uuid/uuid.dart';

class FavoriteEntry {
  final String id;
  final String name;
  final double calories;
  final double protein;

  FavoriteEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
  });

  factory FavoriteEntry.create({
    required String name,
    required double calories,
    required double protein,
  }) {
    return FavoriteEntry(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      protein: protein,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'protein': protein,
      };

  factory FavoriteEntry.fromJson(Map<String, dynamic> json) => FavoriteEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
      );
}
