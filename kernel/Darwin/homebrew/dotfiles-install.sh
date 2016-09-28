#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

# Check for Homebrew
if test ! $(which brew)
then
  info "Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

info "brew bundle"
brew bundle --file=$(dirname $0)/Brewfile
