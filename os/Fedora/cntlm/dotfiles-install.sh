#!/usr/bin/env bash

# Check for brew
if test ! $(which cntlm)
then
  dotfiles_info "cntlm: install..."
  sudo dnf install cntlm
fi
