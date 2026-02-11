# AI-Driven Development Rules

## MANDATORY: 開発完了時のコミット・プッシュ・PR（最重要ルール）

**コードを変更したら、必ず最後にコミット → プッシュ → PR作成まで実行すること。**
**実装だけして終わりにしてはいけない。これはオプションではなく義務である。**

### 手順（省略禁止）

`project.json` の設定を読み取って各コマンドを実行する。

1. **ブランチ作成**（未作成の場合）: `git checkout <main_branch> && git checkout -b <branch_prefix>/<目的>`
2. **コード実装**: 機能実装、バグ修正、リファクタリング等
3. **テスト作成**: ロジックを新規作成・変更した場合、対応するテストを `<test_dir>` に作成・更新
4. **テスト実行 & 修正**: `bash .agent/workflows/run_tests.sh` でテストを実行し、**失敗したら修正するまで次に進まない**
5. **フォーマット & リント**: `bash .agent/workflows/check_and_format.sh`
6. **コミット**: `.agent/workflows/git_commit.md` の規約に**厳密に**従うこと
   - Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:` 等
   - 変更を論理単位に分割して複数コミット
   - Co-Authored-By ヘッダーを付与
7. **プッシュ**: `git push -u origin <branch-name>`
8. **PR作成**: `gh pr create --base <main_branch>`

### 効率化ルール（コマンド数削減）
- **git add + commit を1コマンドで**: `git add <files> && git commit -m "msg"`
- **push + PR作成を1コマンドで**: 新規PR時は `git push -u origin <branch> && gh pr create --base <main_branch> --title "..." --body "..."`
- **既存PRへの追加は push だけ**: `git push origin <branch>` で自動的に PR に反映
- **PATHの事前設定**: `export PATH="$HOME/.local/bin:$PATH"` を gh CLI 使用前に実行

### コミットメッセージ規約
**必ず `.agent/workflows/git_commit.md` を読んでから**コミットメッセージを書くこと。

### gh CLI が使えない場合
**URLを表示して逃げるのではなく、gh CLI をインストールしてからPRを作成すること。**
gh CLI はインストール済み: `~/.local/bin/gh.exe`（PATHに `$HOME/.local/bin` を追加して使用）

---

## MANDATORY: テスト作成・実行・修正（自動化ルール）

**コードを変更したら、テストも必ず作成・実行・修正すること。これは義務である。**

### テスト自動化フロー（省略禁止）
1. **コード変更時**: 対応するテストを `<test_dir>` に作成・更新
2. **テスト実行**: `bash .agent/workflows/run_tests.sh`
3. **失敗時は修正**: テストが失敗したら、テストまたはコードを修正して再実行。**全テストPASSするまでコミットしない**
4. **繰り返し**: 修正 → テスト実行 → PASS確認 のループを全PASS達成まで繰り返す

### テスト作成ルール
- テストファイルの配置先: `<test_dir>` (project.json の test_dir を参照)
- テスト対象の優先順位:
  1. **必須**: 純粋関数、ユーティリティ
  2. **必須**: 状態管理、データ操作ロジック
  3. **必須**: ビジネスロジック、バリデーション
  4. 推奨: 統合テスト（複数モジュールの連携）

### テスト実行コマンド
```bash
# ユニットテスト
bash .agent/workflows/run_tests.sh

# フォーマット + リント + テスト一括実行
bash .agent/workflows/check_and_format.sh
```

---

## project.json 参照ルール

すべてのワークフロースクリプトは `project.json` の設定を読み取って動作する。
言語・フレームワーク固有のコマンドはハードコードせず、project.json から取得すること。

### 設定の読み取り
```bash
# 例: フォーマッタコマンドを取得
FORMATTER=$(cat project.json | python -c "import sys,json; print(json.load(sys.stdin)['formatter']['command'])")
```

---

## Development Workflow (Claude Code)

**冒頭の「MANDATORY: 開発完了時のコミット・プッシュ・PR」セクションを必ず参照すること。**

### 参照ドキュメント
- ブランチ戦略: `.agent/workflows/branch_strategy.md`
- コミット規約: `.agent/workflows/git_commit.md`（**コミット前に必読**）
- フォーマット: `.agent/workflows/check_and_format.sh`

### Pre-Commit Checklist
- [ ] `check_and_format.sh` でフォーマット・リント済み
- [ ] テスト全PASS (`bash .agent/workflows/run_tests.sh`)
- [ ] 新規・変更ロジックに対応するテストあり
- [ ] Conventional Commit format (git_commit.md参照)
- [ ] プッシュ済み、PR作成済み

---

## Code Conventions

project.json の language/framework に応じた命名規則に従うこと。
既存コードのパターンを最優先で踏襲する。
