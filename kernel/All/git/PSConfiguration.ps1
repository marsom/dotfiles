#!/usr/bin/env powershell

function Invoke-gl { git pull --prune $args }
Set-Alias -Name gl Invoke-gl -Force -Option AllScope

function Invoke-glog { git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative }
Set-Alias glog Invoke-glog

function Invoke-gp { git push origin HEAD }
Set-Alias -Name gp -Value Invoke-gp -Force -Option AllScope

function Invoke-gd { git diff }
Set-Alias gd Invoke-gd

function Invoke-gc { git commit }
Set-Alias -Name gc -Value Invoke-gc -Force -Option AllScope

function Invoke-gca { git commit -a $args}
Set-Alias gca Invoke-gca

function Invoke-gco { git checkout $args }
Set-Alias gca Invoke-gco

function Invoke-gcb { git copy-branch-name $args }
Set-Alias gca Invoke-gcb

function Invoke-gb { git branch $args }
Set-Alias gb Invoke-gb

function Invoke-gs { git status -sb $args }
Set-Alias gs Invoke-gs

function Invoke-gac { git add -A; git commit -m }
Set-Alias gca Invoke-gac
