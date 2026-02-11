---
description: 自動的に変更をステージングし、Conventional Commits 形式でコミットする
---

1. `git status` を実行し、変更の有無と対象ファイルを確認してください。
2. 変更がある場合、`git diff` を実行して未ステージの変更内容を把握してください。
3. 変更内容を論理的な単位（例：機能追加、バグ修正、リファクタ、設定変更など）に分割してください。
   - 分割できない場合のみ、1コミットとして扱ってください。
4. 各単位ごとに以下を繰り返してください。※addとcommitは１つのコマンドで行うこと。
   4-1. 対象ファイルのみを `git add <file>` でステージングしてください。
   4-2. `git diff --cached` を実行し、ステージング内容がその単位のみであることを確認してください。
   4-3. [コミットメッセージ規約]に従ってコミットメッセージを作成し、
        `git commit -m "メッセージ"` を実行してください。
5. 全ての変更がコミットされた後、`git status` を再度実行し、作業ツリーがクリーンであることを確認してください。

# コミットメッセージ規約 (Conventional Commits)

メッセージの形式:

```
<type>: <subject>

<body>

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Type (プレフィックス)

変更の種類に応じて、以下のいずれかを選択してください。

- **feat**: 新機能の追加
- **fix**: バグ修正
- **docs**: ドキュメントのみの変更
- **style**: コードの動作に影響しない変更（空白、フォーマット、セミコロン補完など）
- **refactor**: バグ修正や機能追加を含まないコードの変更（リファクタリング）
- **perf**: パフォーマンス改善
- **test**: テストの追加や既存テストの修正
- **chore**: ビルドプロセスやドキュメント生成などの補助ツール、ライブラリの変更

## Subject (要約)

- project.json の `commit_language` に従って記述してください（ja=日本語, en=English）。
- 50文字以内で、変更内容を簡潔に表現してください。

## Body (詳細)

- 必要に応じて、変更の理由（Why）や詳細（What）を記述してください。
- 1行だけの変更など、自明な場合は省略可能です。

## 例 (日本語)

- `feat: ログイン画面にパスワードリセットリンクを追加`
- `fix: 入力値が負の値になるバグを修正`
- `refactor: ユーザークラスの継承構造を整理`
- `docs: READMEにセットアップ手順を追記`

## 例 (English)

- `feat: add password reset link to login page`
- `fix: prevent negative input values`
- `refactor: simplify user class hierarchy`
- `docs: add setup instructions to README`
