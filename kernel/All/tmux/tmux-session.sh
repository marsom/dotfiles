#!/usr/bin/env bash

tmux_kill() {
  while read pid; do
    echo "killing tmux $pid"
    kill -9 $pid 2>/dev/null
  done < <(pgrep -u $(id -u) -f tmux | grep -v -e "^$BASHPID" -e "^$$")
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
