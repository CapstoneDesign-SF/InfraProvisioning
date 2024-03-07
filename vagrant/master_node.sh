#!/usr/bin/env bash

# init kubernetes 
# kubeadm을 사용하여 쿠버네티스 클러스터를 초기화합니다. 토큰과 네트워크 CIDR을 설정하고 마스터 노드의 API 서버 주소를 지정합니다.
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
            --pod-network-cidr=172.16.0.0/16 --apiserver-advertise-address=192.168.29.10 --v=10

# config for master node only 
# kubectl을 사용하여 클러스터에 대한 액세스를 위한 구성 파일을 생성하고 권한을 조정합니다.
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# raw_address for gitcontent
raw_git="raw.githubusercontent.com/CapstoneDesign-SF/InfraProvisioning/main/manifest"
bin_path="/usr/local/bin"

# config for kubernetes's network 
# Calico 네트워크 플러그인을 적용하여 클러스터 내 통신을 구성합니다.
kubectl apply -f https://$raw_git/172.16_net_calico_v3.27.2.yaml

# config metallb for LoadBalancer service
# metallb를 설치하고 LoadBalancer 서비스를 사용할 수 있도록 구성합니다.
kubectl apply -f https://$raw_git/metallb-0.14.3.yaml

# create configmap for metallb (192.168.29.20 - 192.168.29.120)
# metallb를 사용하기 위한 구성 파일을 생성하고 적용합니다.
kubectl apply -f https://$raw_git/metallb-l2config.yaml

# create secret for metallb 
# metallb 시크릿을 생성하여 구성을 보호합니다.
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# install helm
# helm을 설치하고 사용 가능한 디렉토리로 이동합니다.
curl -0L https://get.helm.sh/helm-v3.14.2-linux-amd64.tar.gz > helm-v3.14.2-linux-amd64.tar.gz
tar xvfz helm-v3.14.2-linux-amd64.tar.gz
mv linux-amd64/helm $bin_path/.
rm -f helm-v3.14.2-linux-amd64.tar.gz
rm -rf linux-amd64/

# install bash-completion for kubectl 
yum install bash-completion -y 

# kubectl completion on bash-completion dir
# kubectl을 사용할 때 bash-completion을 활성화하여 명령어 완성 기능을 제공합니다.
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
# kubectl을 'k'로 축약하여 사용할 수 있도록 별칭을 설정하고, 자주 사용하는 apply 명령을 'ka'로 설정하여 편의성을 높입니다.
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# 6443 port 공개
systemctl start firewalld
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --reload
#firewall-cmd --list-all