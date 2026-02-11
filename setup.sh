#!/bin/bash
# setup.sh - プロジェクト初期セットアップスクリプト
# 言語・フレームワークに応じてproject.json、.gitignore、CI等を自動設定する
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "  AI-Driven Development Template Setup"
echo "============================================"
echo ""

# --- プロジェクト名 ---
read -p "プロジェクト名: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "ERROR: プロジェクト名は必須です。"
    exit 1
fi

# --- メインブランチ ---
read -p "メインブランチ名 [main]: " MAIN_BRANCH
MAIN_BRANCH=${MAIN_BRANCH:-main}

# --- コミットメッセージ言語 ---
echo ""
echo "コミットメッセージ・PR言語:"
echo "  1) ja (日本語)"
echo "  2) en (English)"
read -p "選択 [1]: " LANG_CHOICE
case "$LANG_CHOICE" in
    2) COMMIT_LANG="en" ;;
    *) COMMIT_LANG="ja" ;;
esac

# --- 言語選択 ---
echo ""
echo "使用言語:"
echo "  1) Python"
echo "  2) TypeScript/JavaScript (Node.js)"
echo "  3) Go"
echo "  4) Rust"
echo "  5) Java"
echo "  6) C# (.NET)"
echo "  7) GDScript (Godot)"
echo "  8) Other (手動設定)"
read -p "選択: " LANG_CHOICE

case "$LANG_CHOICE" in
    1)
        LANGUAGE="python"
        # --- Pythonフレームワーク ---
        echo ""
        echo "Pythonフレームワーク:"
        echo "  1) None (スクリプト/ライブラリ)"
        echo "  2) FastAPI"
        echo "  3) Django"
        echo "  4) Flask"
        echo "  5) Other"
        read -p "選択 [1]: " FW_CHOICE
        case "$FW_CHOICE" in
            2) FRAMEWORK="fastapi" ;;
            3) FRAMEWORK="django" ;;
            4) FRAMEWORK="flask" ;;
            5) read -p "フレームワーク名: " FRAMEWORK ;;
            *) FRAMEWORK="" ;;
        esac

        # --- Pythonフォーマッタ ---
        echo ""
        echo "フォーマッタ:"
        echo "  1) ruff format (推奨)"
        echo "  2) black"
        echo "  3) autopep8"
        read -p "選択 [1]: " FMT_CHOICE
        case "$FMT_CHOICE" in
            2)
                FORMATTER_CMD="black"
                FORMATTER_ARGS='["src/"]'
                FORMATTER_CHECK='["--check", "src/"]'
                FORMATTER_INSTALL="pip install black"
                ;;
            3)
                FORMATTER_CMD="autopep8"
                FORMATTER_ARGS='["--in-place", "--recursive", "src/"]'
                FORMATTER_CHECK='["--diff", "--recursive", "src/"]'
                FORMATTER_INSTALL="pip install autopep8"
                ;;
            *)
                FORMATTER_CMD="ruff"
                FORMATTER_ARGS='["format", "src/"]'
                FORMATTER_CHECK='["format", "--check", "src/"]'
                FORMATTER_INSTALL="pip install ruff"
                ;;
        esac

        # --- Pythonリンタ ---
        echo ""
        echo "リンタ:"
        echo "  1) ruff check (推奨)"
        echo "  2) flake8"
        echo "  3) pylint"
        read -p "選択 [1]: " LINT_CHOICE
        case "$LINT_CHOICE" in
            2)
                LINTER_CMD="flake8"
                LINTER_ARGS='["src/"]'
                LINTER_INSTALL="pip install flake8"
                ;;
            3)
                LINTER_CMD="pylint"
                LINTER_ARGS='["src/"]'
                LINTER_INSTALL="pip install pylint"
                ;;
            *)
                LINTER_CMD="ruff"
                LINTER_ARGS='["check", "src/"]'
                LINTER_INSTALL="pip install ruff"
                ;;
        esac

        TEST_CMD="pytest"
        TEST_ARGS='["tests/", "-v"]'
        TEST_INSTALL="pip install pytest"
        SOURCE_DIRS='["src/"]'
        TEST_DIR="tests/"
        ;;

    2)
        LANGUAGE="typescript"
        echo ""
        echo "フレームワーク:"
        echo "  1) None (Node.js)"
        echo "  2) Next.js"
        echo "  3) Express"
        echo "  4) NestJS"
        echo "  5) Other"
        read -p "選択 [1]: " FW_CHOICE
        case "$FW_CHOICE" in
            2) FRAMEWORK="nextjs" ;;
            3) FRAMEWORK="express" ;;
            4) FRAMEWORK="nestjs" ;;
            5) read -p "フレームワーク名: " FRAMEWORK ;;
            *) FRAMEWORK="" ;;
        esac

        # --- パッケージマネージャ ---
        echo ""
        echo "パッケージマネージャ:"
        echo "  1) npm"
        echo "  2) pnpm"
        echo "  3) yarn"
        echo "  4) bun"
        read -p "選択 [1]: " PKG_CHOICE
        case "$PKG_CHOICE" in
            2) PKG_MGR="pnpm" ;;
            3) PKG_MGR="yarn" ;;
            4) PKG_MGR="bun" ;;
            *) PKG_MGR="npm" ;;
        esac

        FORMATTER_CMD="npx"
        FORMATTER_ARGS='["prettier", "--write", "src/"]'
        FORMATTER_CHECK='["prettier", "--check", "src/"]'
        FORMATTER_INSTALL="${PKG_MGR} install -D prettier"

        LINTER_CMD="npx"
        LINTER_ARGS='["eslint", "src/"]'
        LINTER_INSTALL="${PKG_MGR} install -D eslint"

        TEST_CMD="npx"
        TEST_ARGS='["vitest", "run"]'
        TEST_INSTALL="${PKG_MGR} install -D vitest"
        SOURCE_DIRS='["src/"]'
        TEST_DIR="tests/"
        ;;

    3)
        LANGUAGE="go"
        FRAMEWORK=""
        FORMATTER_CMD="gofmt"
        FORMATTER_ARGS='["-w", "."]'
        FORMATTER_CHECK='["-l", "."]'
        FORMATTER_INSTALL=""
        LINTER_CMD="golangci-lint"
        LINTER_ARGS='["run"]'
        LINTER_INSTALL="go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        TEST_CMD="go"
        TEST_ARGS='["test", "./..."]'
        TEST_INSTALL=""
        SOURCE_DIRS='["."]'
        TEST_DIR=""
        ;;

    4)
        LANGUAGE="rust"
        FRAMEWORK=""
        FORMATTER_CMD="cargo"
        FORMATTER_ARGS='["fmt"]'
        FORMATTER_CHECK='["fmt", "--check"]'
        FORMATTER_INSTALL=""
        LINTER_CMD="cargo"
        LINTER_ARGS='["clippy", "--", "-D", "warnings"]'
        LINTER_INSTALL=""
        TEST_CMD="cargo"
        TEST_ARGS='["test"]'
        TEST_INSTALL=""
        SOURCE_DIRS='["src/"]'
        TEST_DIR="tests/"
        ;;

    5)
        LANGUAGE="java"
        FRAMEWORK=""
        FORMATTER_CMD="./gradlew"
        FORMATTER_ARGS='["spotlessApply"]'
        FORMATTER_CHECK='["spotlessCheck"]'
        FORMATTER_INSTALL=""
        LINTER_CMD="./gradlew"
        LINTER_ARGS='["checkstyleMain"]'
        LINTER_INSTALL=""
        TEST_CMD="./gradlew"
        TEST_ARGS='["test"]'
        TEST_INSTALL=""
        SOURCE_DIRS='["src/main/"]'
        TEST_DIR="src/test/"
        ;;

    6)
        LANGUAGE="csharp"
        FRAMEWORK=""
        FORMATTER_CMD="dotnet"
        FORMATTER_ARGS='["format"]'
        FORMATTER_CHECK='["format", "--verify-no-changes"]'
        FORMATTER_INSTALL=""
        LINTER_CMD="dotnet"
        LINTER_ARGS='["build", "--no-restore", "/warnaserror"]'
        LINTER_INSTALL=""
        TEST_CMD="dotnet"
        TEST_ARGS='["test"]'
        TEST_INSTALL=""
        SOURCE_DIRS='["src/"]'
        TEST_DIR="tests/"
        ;;

    7)
        LANGUAGE="gdscript"
        echo ""
        echo "Godotバージョン:"
        echo "  1) 4.x"
        echo "  2) 3.x"
        read -p "選択 [1]: " GD_VER
        case "$GD_VER" in
            2) FRAMEWORK="godot3" ;;
            *) FRAMEWORK="godot4" ;;
        esac

        FORMATTER_CMD="gdformat"
        FORMATTER_ARGS='["Scripts/", "Autoload/"]'
        FORMATTER_CHECK='["--check", "Scripts/", "Autoload/"]'
        FORMATTER_INSTALL="pip install gdtoolkit"
        LINTER_CMD="gdlint"
        LINTER_ARGS='["Scripts/", "Autoload/"]'
        LINTER_INSTALL="pip install gdtoolkit"
        TEST_CMD="bash"
        TEST_ARGS='[".agent/workflows/run_tests.sh"]'
        TEST_INSTALL=""
        SOURCE_DIRS='["Scripts/", "Autoload/"]'
        TEST_DIR="tests/"
        ;;

    8)
        LANGUAGE=""
        FRAMEWORK=""
        read -p "言語名: " LANGUAGE
        read -p "フレームワーク名 (なければ空欄): " FRAMEWORK
        echo ""
        echo "以下を手動設定してください:"
        echo "  フォーマッタ、リンタ、テストランナーのコマンドを"
        echo "  project.json に直接記述してください。"
        FORMATTER_CMD=""
        FORMATTER_ARGS='[]'
        FORMATTER_CHECK='[]'
        FORMATTER_INSTALL=""
        LINTER_CMD=""
        LINTER_ARGS='[]'
        LINTER_INSTALL=""
        TEST_CMD=""
        TEST_ARGS='[]'
        TEST_INSTALL=""
        SOURCE_DIRS='["src/"]'
        TEST_DIR="tests/"
        ;;

    *)
        echo "ERROR: 無効な選択です。"
        exit 1
        ;;
esac

# --- project.json 生成 ---
cat > "$SCRIPT_DIR/project.json" << PROJEOF
{
  "project_name": "${PROJECT_NAME}",
  "language": "${LANGUAGE}",
  "framework": "${FRAMEWORK}",
  "main_branch": "${MAIN_BRANCH}",
  "branch_prefix": "ai",
  "source_dirs": ${SOURCE_DIRS},
  "test_dir": "${TEST_DIR}",
  "formatter": {
    "command": "${FORMATTER_CMD}",
    "args": ${FORMATTER_ARGS},
    "check_args": ${FORMATTER_CHECK},
    "install": "${FORMATTER_INSTALL}"
  },
  "linter": {
    "command": "${LINTER_CMD}",
    "args": ${LINTER_ARGS},
    "install": "${LINTER_INSTALL}"
  },
  "test_runner": {
    "command": "${TEST_CMD}",
    "args": ${TEST_ARGS},
    "install": "${TEST_INSTALL}"
  },
  "commit_language": "${COMMIT_LANG}",
  "pr_language": "${COMMIT_LANG}"
}
PROJEOF

echo ""
echo "project.json を生成しました。"

# --- .gitignore 生成 ---
generate_gitignore() {
    # 共通部分
    cat > "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Common ===
*.tmp
*.log
*.bak
*.swp
*~
.DS_Store
Thumbs.db

# IDE
.idea/
*.iml
.vscode/settings.json

# Claude Code local settings
.claude/settings.local.json

GIEOF

    # 言語別追加
    case "$LANGUAGE" in
        python)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Python ===
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
build/
.eggs/
*.egg
.venv/
venv/
env/
.env
.pytest_cache/
.mypy_cache/
.ruff_cache/
htmlcov/
.coverage
GIEOF
            ;;
        typescript|javascript)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Node.js / TypeScript ===
node_modules/
dist/
build/
.next/
.nuxt/
.output/
coverage/
.env
.env.local
*.tsbuildinfo
GIEOF
            ;;
        go)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Go ===
/bin/
/vendor/
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
go.work
GIEOF
            ;;
        rust)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Rust ===
/target/
Cargo.lock
**/*.rs.bk
GIEOF
            ;;
        java)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Java ===
*.class
*.jar
*.war
*.ear
build/
.gradle/
out/
bin/
GIEOF
            ;;
        csharp)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === C# ===
bin/
obj/
*.user
*.suo
*.vs/
*.DotSettings.user
packages/
GIEOF
            ;;
        gdscript)
            cat >> "$SCRIPT_DIR/.gitignore" << 'GIEOF'
# === Godot ===
.godot/
.import/
.mono/
export.cfg
export_credentials.cfg
*.translation
*.uid
.gut_editor_config.json
.gdlint_cache/
GIEOF
            ;;
    esac
}

generate_gitignore
echo ".gitignore を生成しました。"

# --- .editorconfig 生成 ---
cat > "$SCRIPT_DIR/.editorconfig" << 'EDEOF'
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[*.{json,jsonc}]
indent_size = 2

[Makefile]
indent_style = tab
EDEOF

# 言語別 editorconfig 追加
case "$LANGUAGE" in
    typescript|javascript)
        cat >> "$SCRIPT_DIR/.editorconfig" << 'EDEOF'

[*.{ts,tsx,js,jsx}]
indent_size = 2
EDEOF
        ;;
    go)
        cat >> "$SCRIPT_DIR/.editorconfig" << 'EDEOF'

[*.go]
indent_style = tab
EDEOF
        ;;
    gdscript)
        cat >> "$SCRIPT_DIR/.editorconfig" << 'EDEOF'

[*.gd]
indent_style = tab
EDEOF
        ;;
esac

echo ".editorconfig を生成しました。"

# --- GitHub Actions CI 生成 ---
generate_ci() {
    case "$LANGUAGE" in
        python)
            cat > "$SCRIPT_DIR/.github/workflows/ci.yml" << 'CIEOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt 2>/dev/null || true
          pip install ruff pytest
      - name: Format check
        run: ruff format --check src/
      - name: Lint
        run: ruff check src/
      - name: Test
        run: pytest tests/ -v
CIEOF
            ;;
        typescript|javascript)
            cat > "$SCRIPT_DIR/.github/workflows/ci.yml" << 'CIEOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Format check
        run: npx prettier --check src/
      - name: Lint
        run: npx eslint src/
      - name: Test
        run: npx vitest run
CIEOF
            ;;
        go)
            cat > "$SCRIPT_DIR/.github/workflows/ci.yml" << 'CIEOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Format check
        run: test -z "$(gofmt -l .)"
      - name: Lint
        run: |
          go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
          golangci-lint run
      - name: Test
        run: go test ./...
CIEOF
            ;;
        rust)
            cat > "$SCRIPT_DIR/.github/workflows/ci.yml" << 'CIEOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - name: Format check
        run: cargo fmt --check
      - name: Lint
        run: cargo clippy -- -D warnings
      - name: Test
        run: cargo test
CIEOF
            ;;
        *)
            cat > "$SCRIPT_DIR/.github/workflows/ci.yml" << CIEOF
name: CI

on:
  pull_request:
    branches: [${MAIN_BRANCH}]
  push:
    branches: [${MAIN_BRANCH}]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # TODO: Add language-specific setup and checks
      - name: Placeholder
        run: echo "Configure CI for your language"
CIEOF
            ;;
    esac
}

generate_ci
echo ".github/workflows/ci.yml を生成しました。"

# --- ソースディレクトリ・テストディレクトリ作成 ---
if [ -n "$TEST_DIR" ] && [ ! -d "$SCRIPT_DIR/$TEST_DIR" ]; then
    mkdir -p "$SCRIPT_DIR/$TEST_DIR"
    touch "$SCRIPT_DIR/$TEST_DIR/.gitkeep"
fi

# source_dirsからディレクトリ作成（JSONから抽出）
echo "$SOURCE_DIRS" | tr -d '[]"' | tr ',' '\n' | while read -r dir; do
    dir=$(echo "$dir" | tr -d ' /')
    if [ -n "$dir" ] && [ "$dir" != "." ] && [ ! -d "$SCRIPT_DIR/$dir" ]; then
        mkdir -p "$SCRIPT_DIR/$dir"
        touch "$SCRIPT_DIR/$dir/.gitkeep"
    fi
done

# --- Git初期化 ---
if [ ! -d "$SCRIPT_DIR/.git" ]; then
    echo ""
    read -p "Gitリポジトリを初期化しますか? [Y/n]: " GIT_INIT
    case "$GIT_INIT" in
        [nN]*) ;;
        *)
            cd "$SCRIPT_DIR"
            git init -b "$MAIN_BRANCH"
            echo "Gitリポジトリを初期化しました (branch: $MAIN_BRANCH)"
            ;;
    esac
fi

echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "生成ファイル:"
echo "  - project.json       (プロジェクト設定)"
echo "  - .gitignore         (${LANGUAGE}用)"
echo "  - .editorconfig      (エディタ設定)"
echo "  - .github/workflows/ci.yml (CI設定)"
echo ""
echo "次のステップ:"
echo "  1. project.json の内容を確認・調整"
echo "  2. 必要なツールをインストール:"
if [ -n "$FORMATTER_INSTALL" ]; then
    echo "     フォーマッタ: $FORMATTER_INSTALL"
fi
if [ -n "$LINTER_INSTALL" ]; then
    echo "     リンタ:       $LINTER_INSTALL"
fi
if [ -n "$TEST_INSTALL" ]; then
    echo "     テスト:       $TEST_INSTALL"
fi
echo "  3. 開発を開始 (Claude Codeが自動でワークフローを実行します)"
