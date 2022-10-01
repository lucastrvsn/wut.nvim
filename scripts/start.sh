#!/usr/bin/env bash

DIR_NAME=$(dirname -- "${BASH_SOURCE[0]}")
CWD=$(realpath -- "$DIR_NAME")
ROOT_DIR=$(builtin cd "$CWD/.."; pwd)

nvim --clean -u "$ROOT_DIR/scripts/minimal.lua" $@
