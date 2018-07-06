#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    choco install colortool --confirm
    choco install curl --confirm
}
