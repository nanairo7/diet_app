import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/models/favorite_entry.dart';

void main() {
  group('FavoriteEntry - toJson / fromJson', () {
    test('toJsonが正しいMapを返す', () {
      final entry = FavoriteEntry(
        id: 'test-id',
        name: '鶏むね肉',
        calories: 150.0,
        protein: 30.0,
      );
      final json = entry.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], '鶏むね肉');
      expect(json['calories'], 150.0);
      expect(json['protein'], 30.0);
    });

    test('fromJsonが正しくFavoriteEntryを生成する', () {
      final json = {
        'id': 'test-id',
        'name': '鶏むね肉',
        'calories': 150.0,
        'protein': 30.0,
      };
      final entry = FavoriteEntry.fromJson(json);

      expect(entry.id, 'test-id');
      expect(entry.name, '鶏むね肉');
      expect(entry.calories, 150.0);
      expect(entry.protein, 30.0);
    });

    test('toJson → fromJson でラウンドトリップできる', () {
      final original = FavoriteEntry(
        id: 'round-trip-id',
        name: 'サーモン',
        calories: 200.5,
        protein: 25.3,
      );
      final restored = FavoriteEntry.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
    });

    test('FavoriteEntry.createはユニークなIDを生成する', () {
      final a = FavoriteEntry.create(name: 'A', calories: 100, protein: 10);
      final b = FavoriteEntry.create(name: 'B', calories: 200, protein: 20);
      expect(a.id, isNotEmpty);
      expect(a.id, isNot(equals(b.id)));
    });

    test('numをdoubleに正しく変換する', () {
      final json = {
        'id': 'id',
        'name': 'テスト',
        'calories': 100,   // int として渡す
        'protein': 15,     // int として渡す
      };
      final entry = FavoriteEntry.fromJson(json);
      expect(entry.calories, 100.0);
      expect(entry.protein, 15.0);
    });
  });
}
