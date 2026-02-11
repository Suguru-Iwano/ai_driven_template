#!/bin/bash
# check_and_format.sh - コミット前に実行するフォーマット & リント & テストスクリプト
# project.json の設定を読み取って各ツールを実行する

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_JSON="$PROJECT_ROOT/project.json"

if [ ! -f "$PROJECT_JSON" ]; then
    echo "ERROR: project.json が見つかりません。setup.sh を実行してください。"
    exit 1
fi

# --- JSON読み取りユーティリティ ---
# Python, jq, node.js のいずれかで読む
read_json() {
    local key="$1"
    if command -v python3 &>/dev/null; then
        python3 -c "import sys,json; d=json.load(open('$PROJECT_JSON')); print(eval('d$key'))" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import sys,json; d=json.load(open('$PROJECT_JSON')); print(eval('d$key'))" 2>/dev/null
    elif command -v jq &>/dev/null; then
        jq -r "$key" "$PROJECT_JSON" 2>/dev/null
    elif command -v node &>/dev/null; then
        node -e "const d=require('$PROJECT_JSON'); console.log(eval('d$key'))" 2>/dev/null
    else
        echo ""
    fi
}

read_json_array() {
    local key="$1"
    if command -v python3 &>/dev/null; then
        python3 -c "import json; d=json.load(open('$PROJECT_JSON')); print(' '.join(eval('d$key')))" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import json; d=json.load(open('$PROJECT_JSON')); print(' '.join(eval('d$key')))" 2>/dev/null
    else
        echo ""
    fi
}

# --- 設定読み取り ---
FORMATTER_CMD=$(read_json "['formatter']['command']")
FORMATTER_ARGS=$(read_json_array "['formatter']['args']")
LINTER_CMD=$(read_json "['linter']['command']")
LINTER_ARGS=$(read_json_array "['linter']['args']")
TEST_CMD=$(read_json "['test_runner']['command']")
TEST_ARGS=$(read_json_array "['test_runner']['args']")

echo "=== Format & Lint & Test Check ==="
echo ""

# --- 1. フォーマット実行 ---
if [ -n "$FORMATTER_CMD" ]; then
    echo "1. Running formatter ($FORMATTER_CMD)..."
    if command -v "$FORMATTER_CMD" &>/dev/null || [ -f "$FORMATTER_CMD" ]; then
        $FORMATTER_CMD $FORMATTER_ARGS
        echo "✅ Formatting completed"
    else
        echo "⚠️  $FORMATTER_CMD が見つかりません。インストールしてください:"
        INSTALL=$(read_json "['formatter']['install']")
        [ -n "$INSTALL" ] && echo "    $INSTALL"
    fi
    echo ""
else
    echo "1. Formatter: 未設定 (project.json を確認)"
    echo ""
fi

# --- 2. リント実行 ---
if [ -n "$LINTER_CMD" ]; then
    echo "2. Running linter ($LINTER_CMD)..."
    LINT_FAILED=0
    if command -v "$LINTER_CMD" &>/dev/null || [ -f "$LINTER_CMD" ]; then
        $LINTER_CMD $LINTER_ARGS || LINT_FAILED=1
        if [ $LINT_FAILED -eq 1 ]; then
            echo "⚠️  Lint warnings/errors detected."
        else
            echo "✅ Lint check completed - no issues found"
        fi
    else
        echo "⚠️  $LINTER_CMD が見つかりません。インストールしてください:"
        INSTALL=$(read_json "['linter']['install']")
        [ -n "$INSTALL" ] && echo "    $INSTALL"
    fi
    echo ""
else
    echo "2. Linter: 未設定 (project.json を確認)"
    echo ""
fi

# --- 3. 変更されたファイルを確認 ---
echo "3. Modified files after formatting:"
git status --short
echo ""

# --- 4. テスト実行 ---
if [ -n "$TEST_CMD" ]; then
    echo "4. Running tests ($TEST_CMD)..."
    if command -v "$TEST_CMD" &>/dev/null || [ -f "$TEST_CMD" ]; then
        $TEST_CMD $TEST_ARGS || {
            echo ""
            echo "❌ Tests failed! Fix before committing."
            exit 1
        }
        echo "✅ All tests passed"
    else
        echo "⚠️  $TEST_CMD が見つかりません。インストールしてください:"
        INSTALL=$(read_json "['test_runner']['install']")
        [ -n "$INSTALL" ] && echo "    $INSTALL"
    fi
    echo ""
else
    echo "4. Test runner: 未設定 (project.json を確認)"
    echo ""
fi

echo "=== Format & Lint & Test Check Complete ==="
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Stage changes: git add <files>"
echo "  3. Commit: git commit -m \"your message\""
