#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    choco install nodejs.install --confirm
}
