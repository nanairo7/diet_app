# CLAUDE.md

## プロジェクト概要

毎日の食事（カロリー・タンパク質）を記録する Flutter アプリ。
目標体重を設定すると摂取基準カロリー（体重 × 34 kcal）が自動計算され、進捗をリアルタイムで確認できる。

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| フレームワーク | Flutter 3.24.4 / Dart 3.5.4 |
| 状態管理 | Provider (ChangeNotifier) |
| 永続化 | SharedPreferences |
| カレンダー | table_calendar ^3.1.0 |
| 国際化 | intl ^0.19.0（日本語ロケール） |
| テスト | flutter_test |

## ディレクトリ構成

```
lib/
├── constants/   # 文字列定数・テーマ
├── models/      # DailyRecord, FoodEntry
├── providers/   # DietProvider（ChangeNotifier）
├── screens/     # 5画面
├── services/    # StorageService（SharedPreferences）
└── widgets/     # 再利用ウィジェット
docs/
└── design/      # 設計書（下記ルール参照）
test/            # ユニットテスト・ウィジェットテスト
```

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
