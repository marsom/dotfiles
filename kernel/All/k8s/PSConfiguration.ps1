#!/usr/bin/env powershell


function Invoke-k {  kubectl $args }
Set-Alias -Name k Invoke-k -Force -Option AllScope

function Invoke-ks {  kubectl --as=sommermar --as-group=system:masters $args }
Set-Alias -Name ks Invoke-ks -Force -Option AllScope
