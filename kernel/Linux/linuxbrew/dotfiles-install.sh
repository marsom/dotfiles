#!/usr/bin/env bash

# Check for Homebrew
if test ! $(which brew)
then
  dotfiles_info "homebrew: install."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
fi