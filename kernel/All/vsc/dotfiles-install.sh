#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

# Check for brew
if test $(which brew)
then
  dotfiles_info "visual studio code install/update"
  brew cask install visual-studio-code
fi
