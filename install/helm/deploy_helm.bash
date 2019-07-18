#!/bin/bash

kubectl apply -f helm-rbac.yaml

helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"

sleep 30s

helm version 
