#!/usr/bin/env bash

# config for work_nodes only 
# kubeadm을 사용하여 쿠버네티스 클러스터에 워커 노드를 추가합니다. 이를 위해 마스터 노드에서 발급한 토큰과 마스터 노드의 API 서버 주소를 사용합니다.
kubeadm join --token 123456.1234567890123456 \
             --discovery-token-unsafe-skip-ca-verification 192.168.29.10:6443