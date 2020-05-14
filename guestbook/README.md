# GuestBook Example with Separate PlacementRules for Frontend and RedisMaster

This example is trying to convert k8s guest book example [https://kubernetes.io/docs/tutorials/stateless-application/guestbook] into mcm application

Following 2 chart is for mcm-application

1. gbchn
2. gbapp

## What's New

1. Use Kube resource directly in deployable

## Usage

0. Clone the repo, package app charts with `helm package gbapp` `helm package gbchn`
1. Create a namespace for your channel `kubectl create namespace <your_channel_namespace_name>`
2. Install channel chart with GUI or CLI `helm install gbchn -n <your_channel-name> --namespace <your_channel_namespace_name> --tls `
3. Install application chart with GUI or CLI in your project namespace `helm install gbapp -n <release-name> --namespace <project_namespace> --set channel.name=<your_channel-name>,channel.namespace=<your_channel_namespace_name> --tls `
4. Update placement related values to redeploy application
5. Delete application helm release to deregister application `helm delete <release-name> --purge --tls`
6. Delete channel helm release to clean up channel `helm delete <channel-name> --purge --tls`

**Don't intall gbapp to your channel namespace directly, use another one.**

By default gbapp values enables the placement for multicluster, use following CLI to install it with placement disabled: `helm install gbapp -n <your_release_name> --set channel.name=<your_channel_name>,channel.namespace=<your_channel_namespace>,placement.multicluster.enabled=false --tls`

Note that if the multicluster placement is disabled, the application becomes single cluster application. Consequently all pods/services in the application are created in hub cluster directly.  As a result, the application dashboard link won't be shown as no managed clusters are involved.

## PlacementRules

Modify PlacementRules to change placement of Frontend+RedisSlave and RedisMaster respectively.

```
root@icp1x12:~/guestbook-kube-subscription-separate# kubectl get placementrules --all-namespaces -o yaml
apiVersion: v1
items:
- apiVersion: app.ibm.com/v1alpha1
  kind: PlacementRule
  metadata:
    creationTimestamp: "2019-09-05T16:19:42Z"
    generation: 1
    labels:
      app: gbapp
      chart: gbapp-0.1.0
      heritage: Tiller
      release: gbapp
    name: gbapp-gbapp
    namespace: gbapp
    resourceVersion: "3465062"
    selfLink: /apis/app.ibm.com/v1alpha1/namespaces/gbapp/placementrules/gbapp-gbapp
    uid: f7a7a2ff-cff8-11e9-8f57-0e584b6ce354
  spec:
    clusterLabels:
      matchLabels:
        environment: Dev
    clusterReplicas: 1
  status:
    decisions:
    - clusterName: web-dev-1
      clusterNamespace: web-dev-1
- apiVersion: app.ibm.com/v1alpha1
  kind: PlacementRule
  metadata:
    creationTimestamp: "2019-09-05T16:19:42Z"
    generation: 1
    labels:
      app: gbapp
      chart: gbapp-0.1.0
      heritage: Tiller
      release: gbapp
    name: gbapp-gbapp-redismaster
    namespace: gbapp
    resourceVersion: "3465064"
    selfLink: /apis/app.ibm.com/v1alpha1/namespaces/gbapp/placementrules/gbapp-gbapp-redismaster
    uid: f7a7f5be-cff8-11e9-8f57-0e584b6ce354
  spec:
    clusterLabels:
      matchLabels:
        environment: Dev
    clusterReplicas: 1
  status:
    decisions:
    - clusterName: gke-cluster
      clusterNamespace: gke-cluster
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
root@icp1x12:~/guestbook-kube-subscription-separate# 
```