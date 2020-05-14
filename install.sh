#!/bin/bash
set -e
CPK4MCM_FQDN=$(oc get routes -n kube-system icp-console -o jsonpath='{.spec.host}')
ICP_ADMIN_PASSWORD=$(oc -n kube-system get secret platform-auth-idp-credentials -o jsonpath="{.data.admin_password}" | base64 --decode)

cloudctl login "https://${CPK4MCM_FQDN}" --skip-ssl-validation -n default -u admin -p ${ICP_ADMIN_PASSWORD}
helm package guestbook/gbapp

helm package guestbook/gbchn

kubectl create ns gbchn
kubectl create ns gbapp

helm install gbchn-0.1.0.tgz -n guestbook-channel --namespace gbchn --tls
helm install gbapp-0.1.0.tgz -n guestbook-app --namespace gbapp --set channel.name=guestbook-channel,channel.namespace=gbchn --tls

# Cleaning Up
rm gbapp-0.1.0.tgz
rm gbchn-0.1.0.tgz
