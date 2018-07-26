#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_file $(dirname $0)/mvn-cleanup-repository.sh ~/bin/mvn-cleanup-repository
dotfiles_link_file $(dirname $0)/settings.xml ~/.m2/settings.xml
dotfiles_link_file $(dirname $0)/toolchains.xml ~/.m2/toolchains.xml
