#!/bin/bash

set -euo pipefail

_kubeadm_config () {
  mkdir -pv /etc/kubernetes/kubeadm
  cat <<EOT >/etc/kubernetes/kubeadm/config.yaml
# see https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta4/
# apiVersion: kubeadm.k8s.io/v1beta4
# kind: InitConfiguration
# patches:
#   directory: /etc/kubernetes/kubeadm/patches
# ---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
# apiServer:
#   extraArgs:
#     runtime-config: authentication.k8s.io/v1beta1=true
controllerManager:
  extraArgs:
    - name: bind-address
      value: 0.0.0.0
etcd:
  local:
    extraArgs:
      - name: listen-metrics-urls
        value: http://0.0.0.0:2381
# featureGates:
#   RootlessControlPlane: true
kubernetesVersion: v1.31.2
networking:
  podSubnet: 192.168.0.0/16
  serviceSubnet: 10.96.0.0/12
  dnsDomain: cluster.local
scheduler:
  extraArgs:
    - name: bind-address
      value: '0.0.0.0'
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
serverTLSBootstrap: true
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
metricsBindAddress: "0.0.0.0:10249"
mode: ipvs
EOT
  chmod 0600 /etc/kubernetes/kubeadm/config.yaml
}

systemctl enable kubelet
if [[ "$(hostname)" =~ -cp- ]]; then
  _kubeadm_config
fi

# check if not blocked by google
crictl pull registry.k8s.io/pause:3.10
