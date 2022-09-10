# .local/bin
export PATH=$HOME/.local/bin:$PATH

# kind completion
eval "$(kind completion bash)"

# kubectl completion
eval "$(kubectl completion bash)"

# helm completion
eval "$(helm completion bash)"

# istio
export PATH=$HOME/.local/istio-1.21.1/bin:$PATH
eval "$(istioctl completion bash)"
