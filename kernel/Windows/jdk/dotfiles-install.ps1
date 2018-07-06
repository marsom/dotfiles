#!/usr/bin/env powershell

if (Get-Command choco -errorAction SilentlyContinue) {
    choco install jdk10 --confirm
    choco install jdk8 --confirm
}
