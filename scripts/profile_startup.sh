#!/usr/bin/env bash

DIR_NAME=$(dirname -- "${BASH_SOURCE[0]}")
CWD=$(realpath -- "$DIR_NAME")
ROOT_DIR=$(builtin cd "$CWD/.."; pwd)
TEMP_FILE_WUT=$(mktemp)
TEMP_FILE_NORC=$(mktemp)

nvim --headless --startuptime "$TEMP_FILE_WUT" --clean -u "$ROOT_DIR/scripts/minimal.lua" -c "q!"
nvim --headless --startuptime "$TEMP_FILE_NORC" --clean -u NORC -c "q!"

cat "$TEMP_FILE_NORC"
cat "$TEMP_FILE_WUT"
