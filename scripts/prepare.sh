#!/usr/bin/env bash

DIR_NAME=$(dirname -- "${BASH_SOURCE[0]}")
CWD=$(realpath -- "$DIR_NAME")
ROOT_DIR=$(builtin cd "$CWD/.."; pwd)
DOT_PLUGINS_DIR="$ROOT_DIR/.plugins"

if [ ! -d "$DOT_PLUGINS_DIR" ]; then
  printf "\nInstalling wut dependencies...\n"

  mkdir -p "$DOT_PLUGINS_DIR"

  # Cloning treesitter to .plugins
  git clone --depth 999 --no-single-branch --progress \
    https://github.com/nvim-treesitter/nvim-treesitter.git \
    "$DOT_PLUGINS_DIR/nvim-treesitter"

  # Cloning lspconfig to .plugins
  git clone --depth 999 --no-single-branch --progress \
    https://github.com/neovim/nvim-lspconfig.git \
    "$DOT_PLUGINS_DIR/nvim-lspconfig"

  # Install treesitter lua parser
  nvim --headless --clean -u "$ROOT_DIR/scripts/minimal.lua" -c "TSInstallSync! lua | q"

  printf "\n\nCompleted :)"
else
  printf "\nNothing to do, exiting..."
fi

exit 0
