# .local/bin
export PATH=$HOME/.local/bin:$PATH

# kind completion
eval "$(kind completion bash)"

# kubectl completion
eval "$(kubectl completion bash)"

# helm completion
eval "$(helm completion bash)"
