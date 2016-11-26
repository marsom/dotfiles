#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

New-Item -Path "~/.gnupg" -ItemType Directory -ErrorAction SilentlyContinue
Set-DotfilesModuleLink -src "gnupg/gpg.conf" -dst "~/.gnupg/gpg.conf"