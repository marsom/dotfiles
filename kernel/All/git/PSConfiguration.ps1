#!/usr/bin/env powershell

# gpull, gl seams to be a reserved alias :-(
function Invoke-gpull { git pull --prune $args }
Set-Alias gpull Invoke-gpull

# glog
function Invoke-glog { git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative }
Set-Alias glog Invoke-glog

#Set-Alias glog "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#Set-Alias gp 'git push origin HEAD'
#Set-Alias gd 'git diff'
#Set-Alias gc 'git commit'
#Set-Alias gca 'git commit -a'
#Set-Alias gco 'git checkout'
#Set-Alias gcb 'git copy-branch-name'
#Set-Alias gb 'git branch'

function Invoke-gs { git status -sb $args }
Set-Alias gs Invoke-gs

#Set-Alias gac 'git add -A && git commit -m'
