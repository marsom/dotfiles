#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

# Check for brew
if test $(which brew)
then
  dotfiles_info "neovim install/update"
  brew install neovim/neovim/neovim
fi
