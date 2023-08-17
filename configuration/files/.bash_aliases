alias k=kubectl
alias kns=kubens
alias kctx=kubectx

kit() {
  if [ $1 ]; then
    kubectl exec -it $1 -- /bin/bash
  else
    echo "Please pass the pods name."
  fi
}
