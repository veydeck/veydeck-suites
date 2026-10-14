#!/bin/bash

set -euo pipefail

# 批量生成所有套件的 .vsp 交付包，不构建 Docker 镜像。
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_SCRIPT="$BASE_DIR/scripts/package.sh"

if [ ! -x "$PACKAGE_SCRIPT" ]; then
    echo "Error: package script is not executable: $PACKAGE_SCRIPT"
    exit 1
fi

mapfile -t SUITE_DIRS < <(
    find "$BASE_DIR/suites" -mindepth 1 -maxdepth 1 -type d | while read -r suite_dir; do
        if [ -f "$suite_dir/suite.yaml" ] && [ -f "$suite_dir/compose.yaml" ]; then
            printf '%s\n' "$suite_dir"
        fi
    done | sort
)

if [ "${#SUITE_DIRS[@]}" -eq 0 ]; then
    echo "Error: no suite directories found under $BASE_DIR/suites."
    exit 1
fi

echo "Found ${#SUITE_DIRS[@]} suite(s)."
echo

FAILED=()

for SUITE_DIR in "${SUITE_DIRS[@]}"; do
    RELATIVE_SUITE_DIR="${SUITE_DIR#"$BASE_DIR"/}"
    echo "========================================================"
    echo "Packaging: $RELATIVE_SUITE_DIR"
    echo "========================================================"

    if ! "$PACKAGE_SCRIPT" "$RELATIVE_SUITE_DIR"; then
        FAILED+=("$RELATIVE_SUITE_DIR")
    fi
    echo
done

if [ "${#FAILED[@]}" -gt 0 ]; then
    echo "Failed to package ${#FAILED[@]} suite(s):"
    printf '  - %s\n' "${FAILED[@]}"
    exit 1
fi

echo "All suite packages have been created under:"
echo "  $BASE_DIR/dist"
