#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

Set-DotfilesModuleLink -src "bash/bash_profile.symlink" -dst "~/.bash_profile"
Set-DotfilesModuleLink -src "bash/bashrc.symlink" -dst "~/.bashrc"