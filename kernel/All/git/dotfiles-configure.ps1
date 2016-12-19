#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

Set-DotfilesModuleLink -src "git/gitconfig.symlink" -dst "~/.gitconfig"