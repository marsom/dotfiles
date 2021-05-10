alias k='kubectl'
alias ks='kubectl sudo'
alias kevents="kubectl get events --sort-by='.metadata.creationTimestamp'"

source <(kubectl completion bash) 
complete -F __start_kubectl k
