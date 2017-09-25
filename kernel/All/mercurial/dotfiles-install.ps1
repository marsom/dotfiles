#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    if (Get-Command hg -errorAction SilentlyContinue) {
        choco upgrade hg --confirm
    } else {
        choco install hg --confirm
    }
}