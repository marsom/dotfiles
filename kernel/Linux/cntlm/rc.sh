#!/bin/sh

# start cntlm in foreground
function cntlm_start() {
  if [ -z "$1" ]; then
    cntlm -f -c ~/.cntlm.conf
  else
    timeout $1 cntlm -f -c ~/.cntlm.conf
  fi
}
