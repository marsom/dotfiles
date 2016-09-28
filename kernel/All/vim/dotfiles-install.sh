#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_info "VIM: install/update: pathogen"
mkdir -p ~/.vim/autoload ~/.vim/bundle 
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

function install_plugin() {
  local repo=$1 name=$(basename $1 .git)
  if [ -d ~/.vim/bundle/$name ]; then
    dotfiles_info "VIM: update: $name"
    pushd ~/.vim/bundle/$name &>/dev/null
    git pull
    popd &>/dev/null
  else
    dotfiles_info "VIM: install: $name"
    git clone $repo ~/.vim/bundle/$name
  fi
}

install_plugin https://github.com/tpope/vim-sensible.git 
install_plugin https://github.com/fatih/vim-go.git
install_plugin https://github.com/Shougo/neocomplete.vim.git
install_plugin https://github.com/scrooloose/nerdtree.git
install_plugin https://github.com/vim-airline/vim-airline.git
install_plugin https://github.com/altercation/vim-colors-solarized.git

unset install_plugin