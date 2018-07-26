#!/usr/bin/env powershell

Import-Module  "~/.dotfiles/bin/dotfiles.psm1" -ErrorAction Stop

Set-DotfilesModuleLink -src "maven/settings.xml" -dst ~/.m2/settings.xml
Set-DotfilesModuleLink -src "maven/toolchains.xml" -dst ~/.m2/toolchains.xml
