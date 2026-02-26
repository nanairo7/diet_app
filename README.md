# diet_app

毎日の食事（カロリー・タンパク質）を記録するFlutterアプリです。
目標体重を設定すると摂取基準カロリーが自動計算され、進捗をリアルタイムで確認できます。

---

## 機能

- **食事記録**: 食品名・カロリー・タンパク質を入力して記録
- **今日のサマリー**: 合計カロリー・タンパク質・記録数を表示
- **摂取基準カロリー**: 目標体重 × 34 kcal を自動計算し、プログレスバーで進捗表示
- **履歴**: 過去の日別記録を一覧・詳細確認
- **永続化**: SharedPreferences によりアプリを終了しても記録を保持

---

## 動作環境

| ツール | バージョン |
|---|---|
| Flutter | 3.24.4 (stable) |
| Dart | 3.5.4 |
| 対応プラットフォーム | Android / iOS / Web |

---

## セットアップ

### 1. リポジトリのクローン

```cmd
git clone https://github.com/nanairo7/diet_app.git
cd diet_app
```

### 2. 依存パッケージの取得

```cmd
flutter pub get
```

---

## 実行

### アプリの起動（Webブラウザ）

```cmd
flutter run -d chrome
```

### アプリの起動（接続済みデバイス/エミュレーター）

```cmd
flutter run
```

接続されているデバイスを確認する場合:

```cmd
flutter devices
```

特定のデバイスを指定して起動する場合:

```cmd
flutter run -d <device_id>
```

---

## テスト

### 全テストの実行

```cmd
flutter test
```

### 特定ファイルのテストのみ実行

```cmd
flutter test test/providers/diet_provider_test.dart
flutter test test/widgets/summary_card_test.dart
flutter test test/screens/home_screen_test.dart
```

### テスト結果の詳細を表示

```cmd
flutter test --reporter expanded
```

### 期待されるテスト結果

```
00:04 +102: All tests passed!
```

---

## テスト構成

| ファイル | テスト数 | 対象 |
|---|---|---|
| `test/providers/diet_provider_test.dart` | 22 | 状態管理・ビジネスロジック・永続化 |
| `test/widgets/summary_card_test.dart` | 13 | サマリーカードの表示・カロリー目標の状態 |
| `test/widgets/food_entry_tile_test.dart` | 10 | 食事エントリのタイル表示・削除フロー |
| `test/widgets/daily_record_tile_test.dart` | 8 | 日別記録タイルの表示・タップ操作 |
| `test/screens/home_screen_test.dart` | 10 | ホーム画面の表示・タブ切り替え・画面遷移 |
| `test/screens/add_entry_screen_test.dart` | 9 | 食事追加フォームのバリデーション・送信 |
| `test/screens/settings_screen_test.dart` | 10 | 設定画面の表示・カロリープレビュー・保存 |
| `test/screens/history_screen_test.dart` | 7 | 履歴画面のカレンダー表示・日付選択 |
| `test/screens/day_detail_screen_test.dart` | 6 | 日別詳細画面の表示・集計値 |
| `test/widget_test.dart` | 1 | アプリ全体のビルド確認 |
| **合計** | **102** | |

---

## プロジェクト構成

```
lib/
├── constants/
│   ├── app_strings.dart    # UI文字列定数（日本語）
│   └── app_theme.dart      # Material 3 テーマ設定
├── models/
│   ├── daily_record.dart   # 日別記録モデル
│   └── food_entry.dart     # 食事エントリモデル
├── providers/
│   └── diet_provider.dart  # 状態管理（ChangeNotifier）
├── screens/
│   ├── home_screen.dart        # ホーム画面（今日の記録・履歴タブ）
│   ├── add_entry_screen.dart   # 食事追加画面
│   ├── history_screen.dart     # 履歴一覧画面
│   ├── day_detail_screen.dart  # 日別詳細画面
│   └── settings_screen.dart    # 設定画面（目標体重）
├── services/
│   └── storage_service.dart    # SharedPreferences による永続化
├── widgets/
│   ├── summary_card.dart        # サマリーカード
│   ├── food_entry_tile.dart     # 食事エントリのリストタイル
│   └── daily_record_tile.dart   # 日別記録のリストタイル
└── main.dart                   # アプリエントリーポイント

test/
├── providers/
│   └── diet_provider_test.dart
├── screens/
│   ├── home_screen_test.dart
│   ├── add_entry_screen_test.dart
│   ├── settings_screen_test.dart
│   ├── history_screen_test.dart
│   └── day_detail_screen_test.dart
├── widgets/
│   ├── summary_card_test.dart
│   ├── food_entry_tile_test.dart
│   └── daily_record_tile_test.dart
└── widget_test.dart
```

---

## 依存パッケージ

| パッケージ | バージョン | 用途 |
|---|---|---|
| [provider](https://pub.dev/packages/provider) | ^6.1.2 | 状態管理（ChangeNotifier） |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.3.4 | ローカルデータ永続化 |
| [intl](https://pub.dev/packages/intl) | ^0.19.0 | 日本語日付フォーマット |
| [uuid](https://pub.dev/packages/uuid) | ^4.5.1 | 食事エントリのID生成 |
| [table_calendar](https://pub.dev/packages/table_calendar) | ^3.1.0 | 履歴画面のカレンダー表示 |