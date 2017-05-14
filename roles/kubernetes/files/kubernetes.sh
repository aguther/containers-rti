# set configuration file for kubectl
KUBECONFIG=/etc/kubernetes/admin.conf
export KUBECONFIG

# enable completion for kubectl
source <(/usr/bin/kubectl completion bash)
