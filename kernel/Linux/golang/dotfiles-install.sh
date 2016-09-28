#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

if [ ! -d ~/go ]; then
  info "Installing golang for you."
  curl https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz -o ~/go.tar.gz
  tar -C ~/ -x -f ~/go.tar.gz
  rm ~/go.tar.gz
fi

export GOPATH=~/gopath
export GOROOT=~/go
export PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}

info "Installing some tools: golang.org/x/tools/cmd/"
go get -u golang.org/x/tools/cmd/goimports
go get -u golang.org/x/tools/cmd/gorename
go get -u golang.org/x/tools/cmd/guru
go get -u golang.org/x/tools/cmd/present

info "Installing some tools: github.com/golang"
go get -u github.com/golang/lint/golint

info "Installing some tools: github.com"
go get -u github.com/jstemmer/gotags
go get -u github.com/rogpeppe/godef
go get -u github.com/kisielk/errcheck
go get -u github.com/nsf/gocode
