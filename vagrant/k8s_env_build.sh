#!/usr/bin/env bash

# vim configuration 
# vi 편집기를 vim으로 대체하는 alias를 /etc/profile 파일에 추가합니다.
echo 'alias vi=vim' >> /etc/profile

# swapoff -a to disable swapping
# 시스템의 스왑을 비활성화합니다.
swapoff -a
# sed to comment the swap partition in /etc/fstab
# /etc/fstab 파일에서 스왑 파티션을 주석 처리하여 스왑이 부팅 시 자동으로 마운트되지 않도록 설정합니다.
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# Set SELinux in permissive mode (effectively disabling it)
# SELinux를 permissive 모드로 설정하여 비활성화합니다.
setenforce 0
# /etc/selinux/config 파일에서 SELinux 설정을 permissive로 변경합니다.
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# kubernetes repo
# Kubernetes 저장소 설정
# Google 저장소 주소를 설정합니다.
gg_pkg="packages.cloud.google.com/yum/doc" # Due to shorten addr for key
# 파일을 생성하고 Kubernetes 패키지를 설치할 수 있는 저장소 정보를 추가합니다.
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# add docker-ce repo
# Docker 저장소 설정
# yum-utils를 설치합니다.
yum install yum-utils -y 
# Docker 저장소 정보를 /etc/yum.repos.d/docker-ce.repo에 추가합니다.
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# RHEL/CentOS 7 have reported traffic issues being routed incorrectly due to iptables bypassed
# iptables 설정:
# /etc/sysctl.d/k8s.conf 파일을 생성하고 네트워크 브릿지 관련 설정을 추가합니다.
# br_netfilter 모듈을 로드합니다.
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
modprobe br_netfilter

# local small dns & vagrant cannot parse and delivery shell code.
# 호스트 파일(/etc/hosts)에 로컬 DNS 주소를 추가합니다.
echo "192.168.29.10 m-k8s" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.29.1$i w$i-k8s" >> /etc/hosts; done

# config DNS  
# /etc/resolv.conf 파일에 클라우드 플레어와 구글의 DNS 서버 주소를 추가합니다.
cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF