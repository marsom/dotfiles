#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

# Check for brew
if test ! $(which go)
then
  dotfiles_info "slex: install/update"
  go get -u github.com/crosbymichael/slex
fi
