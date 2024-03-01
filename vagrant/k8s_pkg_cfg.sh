#!/usr/bin/env bash

# install util packages 
# epel-release, vim-enhanced 및 git과 같은 유틸리티 패키지를 설치합니다.
yum install epel-release -y
yum install vim-enhanced -y
yum install git -y

# install docker 
# Docker 및 관련 패키지를 설치합니다.
yum install docker-ce-$2 docker-ce-cli-$2 containerd.io-$3 -y

# fix - [ERROR CRI]: container runtime is not running
# disabled_plugins cri 주석 처리
# containerd 설정 변경:
# containerd 구성 파일을 수정하여 container runtime 오류를 수정합니다.
sed -i '/"cri"/ s/^/#/' /etc/containerd/config.toml
systemctl restart containerd

# install kubernetes
# both kubelet and kubectl will install by dependency
# but aim to latest version. so fixed version by manually
# 쿠버네티스와 관련된 패키지를 설치합니다.
yum install kubelet-$1 kubectl-$1 kubeadm-$1 -y 

# Ready to install for k8s 
# Docker 및 kubelet을 시스템 부팅 시 자동으로 실행하도록 구성합니다.
systemctl enable --now docker
systemctl enable --now kubelet

# docker daemon config for systemd from cgroupfs & restart 
# Docker 데몬 설정을 변경하여 systemd의 cgroupfs를 사용하도록 설정하고 Docker를 다시 시작합니다.
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl daemon-reload && systemctl restart docker