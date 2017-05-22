#!/usr/bin/env bash

set -e

tmux_kill() {
  pkill -u $(id -u) tmux || true
}

case "$1" in
kill)
  tmux_kill
  ;;
renew)
  tmux_kill
  if [ -r ~/.tmux-session ]; then
    source ~/.tmux-session
  fi
  tmux a
  ;;
* )
  echo "valid commands: kill, renew" >&2
  exit 1
esac
