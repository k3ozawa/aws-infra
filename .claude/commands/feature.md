---
description: 新機能実装用のブランチを作成してコミット・プッシュする
argument-hint: "<branch-suffix> <機能の説明>"
---

以下の手順で新機能の実装作業を行ってください。

## 引数

`$ARGUMENTS` の形式: `<branch-suffix> <機能の説明>`

例: `add-cloudtrail CloudTrailモジュールを追加`

branch-suffix が省略された場合は機能の説明から適切な名前を推測してください。

## 手順

1. **main ブランチに切り替え**
   ```bash
   git checkout main
   ```

2. **feat ブランチを作成**
   ```bash
   git checkout -b feat/<branch-suffix>
   ```

3. **機能を実装**
   - ユーザーから指示された機能内容を実装する
   - 実装前に関連ファイルを必ず Read で確認する

4. **差分を確認**
   ```bash
   git diff
   ```

5. **コミット（Conventional Commits 形式）**
   ```bash
   git add <変更ファイル>
   git commit -m "feat: <説明>"
   ```

6. **プッシュ**
   ```bash
   git push -u origin feat/<branch-suffix>
   ```

完了後、PR 作成用の URL を表示してください。
