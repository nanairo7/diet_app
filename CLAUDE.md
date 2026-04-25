# CLAUDE.md

## プロジェクト概要

毎日の食事（カロリー・タンパク質）を記録する Flutter iOS アプリ。
目標体重を設定すると摂取基準カロリー（体重 × 34 kcal）が自動計算され、進捗をリアルタイムで確認できる。

## プラットフォーム・配信

- **iOS 専用**（Android ビルドは `pubspec.yaml` で無効化済み）
- 配信: Codemagic CI/CD → TestFlight 自動配信
- ビルド番号は Codemagic の `$BUILD_NUMBER` で自動インクリメント

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| フレームワーク | Flutter 3.24.4 / Dart 3.5.4 |
| 状態管理 | Provider (ChangeNotifier) |
| 永続化 | SharedPreferences |
| カレンダー | table_calendar ^3.1.0 |
| 国際化 | intl ^0.19.0（日本語ロケール） |
| グラフ | fl_chart ^0.69.0 |
| 通知 | flutter_local_notifications ^18.0.1 |
| タイムゾーン | flutter_timezone ^1.0.6 |
| 共有 | share_plus ^10.1.4 |
| テスト | flutter_test |
| CI/CD | Codemagic（TestFlight 自動配信） |

## ディレクトリ構成

```
lib/
├── constants/   # 文字列定数・テーマ
├── models/      # DailyRecord, FoodEntry, FavoriteEntry, NotificationSlot
├── providers/   # DietProvider（ChangeNotifier）
├── screens/     # 6画面（Home, History, Graph, Settings, Favorites, DayDetail）
├── services/    # StorageService, NotificationService
└── widgets/     # 再利用ウィジェット
docs/
└── design/      # 設計書（下記ルール参照）
test/            # ユニットテスト・ウィジェットテスト
```

---

## ブランチ運用ルール

- バグ修正・機能追加は**必ず `main` の最新から新規ブランチを作成**すること
- 既存ブランチからの派生は禁止（差分混入を防ぐ）
- ブランチ命名規則: `feat/<機能名>` / `fix/<バグ名>`
- 作業完了後は必ず PR を作成すること（`main` への直接プッシュ禁止）
- PR は 1 機能 / 1 バグ修正につき 1 つ

## コミットメッセージ規約

プレフィックスを必ず付ける:

| プレフィックス | 用途 |
|---|---|
| `feat:` | 新機能 |
| `fix:` | バグ修正 |
| `docs:` | ドキュメントのみの変更 |
| `refactor:` | 動作を変えないリファクタリング |
| `test:` | テストのみの変更 |

---

## 設計書の管理ルール

- 新機能を実装したら `docs/design/` の該当ドキュメントも更新すること
- API の変更時は `docs/design/api-design.md` のシーケンス図を更新すること
- データモデルの変更時は `docs/design/data-model.md` の ER 図を更新すること
- 画面の追加・変更時は `docs/design/screen-flow.md` の画面フロー図を更新すること
- アーキテクチャの変更時は `docs/design/architecture.md` のレイヤー図を更新すること

### 設計書一覧

| ファイル | 更新タイミング |
|---|---|
| `docs/design/architecture.md` | レイヤー構成・依存関係の変更時 |
| `docs/design/data-model.md` | モデルのフィールド追加・変更・削除時 |
| `docs/design/screen-flow.md` | 画面の追加・削除・遷移変更時 |
| `docs/design/api-design.md` | StorageService やその他サービスの API 変更時 |

---

## 開発ルール

- コミット前に必ず `flutter test` がパスすることを確認する
- 新しいウィジェット・画面を追加したら対応するテストも追加する
- テキスト文字列は `lib/constants/app_strings.dart` に定義してハードコードしない
- 日付キーは `YYYY-MM-DD` 形式（`StorageService` の命名規則に従う）

---

## 既知の実装パターンと注意点

### 通知スケジュール
- `NotificationService.scheduleSlots()` は内部で `init()` を呼ぶ設計になっている
- `init()` は `tz.initializeTimeZones()` + `FlutterTimezone` でデバイスのタイムゾーンを
  `tz.local` に設定する。これを行わないと通知がデバイスタイムゾーン分ずれる
- `requestPermission()` を呼ぶ前には別途 `init()` が必要（プラグイン初期化のため）

### 共有ボタン（iOS 18+）
- `Share.share()` には `sharePositionOrigin` を渡すこと
- `GlobalKey` でボタンウィジェットの画面座標を取得して渡す
- 渡さないと iOS 18+ の iPhone で共有シートが表示されない

### バグ調査・修正のフロー
- バグ修正を始める前に必ず原因調査を行い、報告すること
- 調査結果を確認してから修正に着手する（見当違いな修正を防ぐため）
