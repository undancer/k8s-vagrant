#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "执行前置条件检查"
echo "  检查主机名"
uname -a
echo "  检查网络"
ip link
echo "  检查product_uuid"
cat /sys/class/dmi/id/product_uuid

echo "  关闭防火墙"
#systemctl stop firewalld
#systemctl disable firewalld

echo "  关闭SELinux"
#apt install selinux-utils
#getenforce
#setenforce 0

echo "  关闭Swap"
swapoff -a
mount -a
free -m
cat /proc/swaps

echo "  设置iptables"
apt install -y bridge-utils
modprobe bridge
modprobe br_netfilter

cat <<EOF >  /etc/sysctl.d/99-k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF

sysctl --system

echo "  使用apt国内镜像"