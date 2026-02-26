# API 設計

## DietProvider (`lib/providers/diet_provider.dart`)

### メソッド一覧

| メソッド | 引数 | 戻り値 | 説明 |
|---|---|---|---|
| `init()` | なし | `Future<void>` | ストレージを初期化し、全日付・目標体重・今日の記録をロード |
| `addEntry()` | `name`, `calories`, `protein` | `Future<void>` | UUID を生成して今日の記録にエントリを追加・保存 |
| `deleteEntry()` | `entryId: String` | `Future<void>` | 今日の記録から指定 ID のエントリを削除・保存 |
| `setTargetWeight()` | `weight: double` | `Future<void>` | 目標体重を設定・保存。`calorieGoal` が自動更新される |
| `getRecordForDate()` | `dateKey: String` | `DailyRecord?` | 指定日の記録を返す。今日はメモリ、過去日はストレージから取得 |

### ゲッター一覧

| ゲッター | 型 | 説明 |
|---|---|---|
| `todayRecord` | `DailyRecord` | 今日の日付の記録 |
| `allDates` | `List<String>` | 記録済み全日付キーの一覧（降順） |
| `isLoading` | `bool` | 初期化完了前は `true` |
| `targetWeight` | `double?` | 目標体重。未設定時は `null` |
| `calorieGoal` | `double?` | `targetWeight * 34`。未設定時は `null` |

---

## StorageService (`lib/services/storage_service.dart`)

### メソッド一覧

| メソッド | 引数 | 戻り値 | 副作用 |
|---|---|---|---|
| `init()` | なし | `Future<void>` | SharedPreferences インスタンスを初期化 |
| `saveDailyRecord()` | `record: DailyRecord` | `Future<void>` | `diet_YYYY-MM-DD` キーに JSON 保存。日付リストにも追加（重複なし・降順ソート） |
| `loadDailyRecord()` | `dateKey: String` | `DailyRecord?` | `diet_YYYY-MM-DD` から JSON を読み込みデシリアライズ。未存在時は `null` |
| `getAllRecordDates()` | なし | `List<String>` | 降順ソート済み日付キーの一覧を返す |
| `saveTargetWeight()` | `weight: double` | `Future<void>` | `diet_target_weight` キーに保存 |
| `loadTargetWeight()` | なし | `double?` | `diet_target_weight` を返す。未設定時は `null` |

---

## シーケンス図

### 食事エントリの追加（addEntry）

```mermaid
sequenceDiagram
    participant UI as AddEntryScreen
    participant DP as DietProvider
    participant SS as StorageService
    participant SP as SharedPreferences

    UI->>DP: addEntry(name, calories, protein)
    DP->>DP: FoodEntry を生成（UUID）
    DP->>DP: todayRecord.entries に追加
    DP->>SS: saveDailyRecord(todayRecord)
    SS->>SP: setString("diet_YYYY-MM-DD", json)
    SS->>SP: getStringList("diet_date_list")
    SP-->>SS: dateList
    SS->>SP: setStringList("diet_date_list", sorted)
    SS-->>DP: 完了
    DP->>SS: getAllRecordDates()
    SS-->>DP: allDates
    DP->>DP: notifyListeners()
    DP-->>UI: Consumer が rebuild
```

### 食事エントリの削除（deleteEntry）

```mermaid
sequenceDiagram
    participant UI as FoodEntryTile
    participant DP as DietProvider
    participant SS as StorageService
    participant SP as SharedPreferences

    UI->>UI: 削除確認ダイアログを表示
    UI->>DP: deleteEntry(entryId)
    DP->>DP: entries.removeWhere(id == entryId)
    DP->>SS: saveDailyRecord(todayRecord)
    SS->>SP: setString("diet_YYYY-MM-DD", json)
    SS-->>DP: 完了
    DP->>DP: notifyListeners()
    DP-->>UI: Consumer が rebuild
```

### アプリ起動時の初期化（init）

```mermaid
sequenceDiagram
    participant App as main.dart
    participant DP as DietProvider
    participant SS as StorageService
    participant SP as SharedPreferences

    App->>DP: DietProvider(storage)..init()
    DP->>SS: init()
    SS->>SP: getInstance()
    SP-->>SS: prefs
    DP->>SS: getAllRecordDates()
    SS-->>DP: allDates
    DP->>SS: loadTargetWeight()
    SS-->>DP: targetWeight (or null)
    DP->>SS: loadDailyRecord(todayKey)
    SS-->>DP: todayRecord (or null)
    DP->>DP: isLoading = false
    DP->>DP: notifyListeners()
```
