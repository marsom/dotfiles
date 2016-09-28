#!/bin/sh

# Check for Homebrew
if test ! $(which cntlm)
then
  echo "  Installing cntlm for you."
  sudo dnf install cntlm
fi
