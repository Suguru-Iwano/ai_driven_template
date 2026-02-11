#!/bin/bash
# run_tests.sh - project.json の設定に基づいてテストを実行する

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_JSON="$PROJECT_ROOT/project.json"

if [ ! -f "$PROJECT_JSON" ]; then
    echo "ERROR: project.json が見つかりません。setup.sh を実行してください。"
    exit 1
fi

# --- JSON読み取り ---
read_json() {
    local key="$1"
    if command -v python3 &>/dev/null; then
        python3 -c "import json; d=json.load(open('$PROJECT_JSON')); print(eval('d$key'))" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import json; d=json.load(open('$PROJECT_JSON')); print(eval('d$key'))" 2>/dev/null
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

TEST_CMD=$(read_json "['test_runner']['command']")
TEST_ARGS=$(read_json_array "['test_runner']['args']")

echo "=== Unit Tests ==="
echo ""

if [ -z "$TEST_CMD" ]; then
    echo "WARNING: test_runner が project.json に設定されていません。"
    echo "project.json の test_runner セクションを設定してください。"
    exit 0
fi

if ! command -v "$TEST_CMD" &>/dev/null && [ ! -f "$TEST_CMD" ]; then
    echo "WARNING: $TEST_CMD が見つかりません。"
    INSTALL=$(read_json "['test_runner']['install']")
    if [ -n "$INSTALL" ]; then
        echo "インストール: $INSTALL"
    fi
    exit 0
fi

echo "Running: $TEST_CMD $TEST_ARGS"
echo ""

$TEST_CMD $TEST_ARGS
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ テストが失敗しました (exit code: $EXIT_CODE)"
    echo "テストを修正してから再度実行してください。"
    exit 1
fi

echo ""
echo "=== All Tests Passed ==="
