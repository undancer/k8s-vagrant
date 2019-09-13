#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cat <<EOF >/etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
#  Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet

mkdir -p /vagrant/certs/

if [[ ! -f "/vagrant/certs/ca.crt" ]]; then
  kubeadm init phase certs etcd-ca
  cp /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.key /vagrant/certs/
else
  mkdir -p /etc/kubernetes/pki/etcd/
  cp /vagrant/certs/ca.crt /vagrant/certs/ca.key /etc/kubernetes/pki/etcd/
fi

HOST=$1
NAME=$2
CLUSTER=$3
mkdir -p /tmp/etcd/
cat <<EOF >/tmp/etcd/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${CLUSTER}
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF

kubeadm init phase certs etcd-server --config=/tmp/etcd/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/tmp/etcd/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/tmp/etcd/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/tmp/etcd/kubeadmcfg.yaml

kubeadm init phase etcd local --config=/tmp/etcd/kubeadmcfg.yaml
