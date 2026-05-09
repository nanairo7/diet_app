import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/services/storage_service.dart';
// ignore: unused_import
import 'package:diet_app/models/notification_slot.dart';

void main() {
  late StorageService storage;
  late DietProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    provider = DietProvider(storage);
    await provider.init();
  });

  group('DietProvider - 初期化', () {
    test('初期化後はローディングが完了している', () {
      expect(provider.isLoading, isFalse);
    });

    test('初期状態では今日の記録が空', () {
      expect(provider.todayRecord.entries, isEmpty);
    });

    test('初期状態では目標体重がnull', () {
      expect(provider.targetWeight, isNull);
    });

    test('初期状態ではカロリー目標がnull', () {
      expect(provider.calorieGoal, isNull);
    });

    test('初期状態では全日付リストが空', () {
      expect(provider.allDates, isEmpty);
    });

    test('初期状態では通知スロットが3件', () {
      expect(provider.notificationSlots.length, 3);
    });

    test('初期状態では全スロットがOFF', () {
      expect(provider.notificationSlots[0].enabled, isFalse); // 朝
      expect(provider.notificationSlots[1].enabled, isFalse); // 昼
      expect(provider.notificationSlots[2].enabled, isFalse); // 晩
    });
  });

  group('DietProvider - addEntry', () {
    test('エントリを追加すると今日の記録に反映される', () async {
      await provider.addEntry(name: '鶏むね肉', calories: 150, protein: 30);
      expect(provider.todayRecord.entries.length, 1);
      expect(provider.todayRecord.entries.first.name, '鶏むね肉');
      expect(provider.todayRecord.entries.first.calories, 150);
      expect(provider.todayRecord.entries.first.protein, 30);
    });

    test('複数エントリを追加できる', () async {
      await provider.addEntry(name: '卵', calories: 80, protein: 6);
      await provider.addEntry(name: '牛乳', calories: 67, protein: 3.4);
      expect(provider.todayRecord.entries.length, 2);
    });

    test('エントリ追加後に全日付リストが更新される', () async {
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);
      expect(provider.allDates, isNotEmpty);
    });

    test('エントリ追加後にnotifyListenersが呼ばれる（カウンタで確認）', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);
      expect(notifyCount, greaterThan(0));
    });
  });

  group('DietProvider - deleteEntry', () {
    test('エントリを削除すると今日の記録から消える', () async {
      await provider.addEntry(name: '豆腐', calories: 50, protein: 5);
      final entryId = provider.todayRecord.entries.first.id;
      await provider.deleteEntry(entryId);
      expect(provider.todayRecord.entries, isEmpty);
    });

    test('存在しないIDを削除してもエラーにならない', () async {
      await provider.addEntry(name: '豆腐', calories: 50, protein: 5);
      expect(
        () async => provider.deleteEntry('non-existent-id'),
        returnsNormally,
      );
    });

    test('複数エントリのうち特定のエントリだけ削除できる', () async {
      await provider.addEntry(name: '食品A', calories: 100, protein: 10);
      await provider.addEntry(name: '食品B', calories: 200, protein: 20);
      final idToDelete = provider.todayRecord.entries.first.id;
      await provider.deleteEntry(idToDelete);
      expect(provider.todayRecord.entries.length, 1);
      expect(provider.todayRecord.entries.first.name, '食品B');
    });
  });

  group('DietProvider - setTargetWeight', () {
    test('目標体重を設定できる', () async {
      await provider.setTargetWeight(70.0);
      expect(provider.targetWeight, 70.0);
    });

    test('目標体重設定後にカロリー目標が計算される', () async {
      await provider.setTargetWeight(70.0);
      expect(provider.calorieGoal, 70.0 * 34);
    });

    test('目標体重を更新できる', () async {
      await provider.setTargetWeight(70.0);
      await provider.setTargetWeight(65.0);
      expect(provider.targetWeight, 65.0);
      expect(provider.calorieGoal, 65.0 * 34);
    });

    test('目標体重設定後にnotifyListenersが呼ばれる', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.setTargetWeight(70.0);
      expect(notifyCount, greaterThan(0));
    });
  });

  group('DietProvider - calorieGoal', () {
    test('目標体重がnullならカロリー目標もnull', () {
      expect(provider.calorieGoal, isNull);
    });

    test('カロリー目標は目標体重 × 34', () async {
      await provider.setTargetWeight(60.0);
      expect(provider.calorieGoal, 60.0 * 34);
    });
  });

  group('DietProvider - getRecordForDate', () {
    test('今日の日付キーで今日の記録を取得できる', () async {
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);
      final todayKey = provider.todayRecord.dateKey;
      final record = provider.getRecordForDate(todayKey);
      expect(record, isNotNull);
      expect(record!.entries.length, 1);
    });

    test('存在しない日付ではnullが返る', () {
      final record = provider.getRecordForDate('1900-01-01');
      expect(record, isNull);
    });
  });

  group('DietProvider - お気に入り', () {
    test('初期状態ではお気に入りが空', () {
      expect(provider.favorites, isEmpty);
    });

    test('お気に入りを追加できる', () async {
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      expect(provider.favorites.length, 1);
      expect(provider.favorites.first.name, '鶏むね肉');
      expect(provider.favorites.first.calories, 150);
      expect(provider.favorites.first.protein, 30);
    });

    test('複数のお気に入りを追加できる', () async {
      await provider.addFavorite(name: '食品A', calories: 100, protein: 10);
      await provider.addFavorite(name: '食品B', calories: 200, protein: 20);
      expect(provider.favorites.length, 2);
    });

    test('お気に入りをIDで削除できる', () async {
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      final id = provider.favorites.first.id;
      await provider.removeFavorite(id);
      expect(provider.favorites, isEmpty);
    });

    test('複数のうち特定のお気に入りだけ削除できる', () async {
      await provider.addFavorite(name: '食品A', calories: 100, protein: 10);
      await provider.addFavorite(name: '食品B', calories: 200, protein: 20);
      final idToDelete = provider.favorites.first.id;
      await provider.removeFavorite(idToDelete);
      expect(provider.favorites.length, 1);
      expect(provider.favorites.first.name, '食品B');
    });

    test('お気に入り追加後にnotifyListenersが呼ばれる', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.addFavorite(name: 'テスト', calories: 100, protein: 10);
      expect(notifyCount, greaterThan(0));
    });

    test('お気に入りがinit後に復元される', () async {
      await provider.addFavorite(name: 'ご飯', calories: 250, protein: 4);

      final provider2 = DietProvider(storage);
      await provider2.init();

      expect(provider2.favorites.length, 1);
      expect(provider2.favorites.first.name, 'ご飯');
    });
  });

  group('DietProvider - addEntryForDate', () {
    test('過去の日付にエントリを追加できる', () async {
      await provider.addEntryForDate(
        dateKey: '2024-01-01',
        name: '朝食',
        calories: 300,
        protein: 15,
      );
      final record = provider.getRecordForDate('2024-01-01');
      expect(record, isNotNull);
      expect(record!.entries.length, 1);
      expect(record.entries.first.name, '朝食');
    });

    test('過去日付への追加でallDatesが更新される', () async {
      await provider.addEntryForDate(
        dateKey: '2024-01-01',
        name: '昼食',
        calories: 500,
        protein: 20,
      );
      expect(provider.allDates, contains('2024-01-01'));
    });

    test('今日の日付でaddEntryForDateを呼ぶとtodayRecordに反映される', () async {
      final todayKey = provider.todayRecord.dateKey;
      await provider.addEntryForDate(
        dateKey: todayKey,
        name: '夕食',
        calories: 700,
        protein: 30,
      );
      expect(provider.todayRecord.entries.length, 1);
      expect(provider.todayRecord.entries.first.name, '夕食');
    });

    test('記録のない過去日付に追加すると新規DailyRecordが作成される', () async {
      expect(provider.getRecordForDate('2023-06-15'), isNull);

      await provider.addEntryForDate(
        dateKey: '2023-06-15',
        name: 'テスト食品',
        calories: 100,
        protein: 5,
      );

      final record = provider.getRecordForDate('2023-06-15');
      expect(record, isNotNull);
      expect(record!.dateKey, '2023-06-15');
    });
  });

  group('DietProvider - 永続化', () {
    test('init後に保存済みの目標体重が復元される', () async {
      await provider.setTargetWeight(75.0);

      // 新しいproviderインスタンスで再読み込み
      final provider2 = DietProvider(storage);
      await provider2.init();

      expect(provider2.targetWeight, 75.0);
    });

    test('init後に保存済みのエントリが復元される', () async {
      await provider.addEntry(name: 'ご飯', calories: 250, protein: 4);

      final provider2 = DietProvider(storage);
      await provider2.init();

      expect(provider2.todayRecord.entries.length, 1);
      expect(provider2.todayRecord.entries.first.name, 'ご飯');
    });
  });
}
