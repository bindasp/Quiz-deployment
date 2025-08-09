## Table of contents

- [General info](#general-info)
- [Technologies](#technologies)
- [Setup](#setup)
- [Illustrations](#illustrations)

## General info

---

## Technologies

---

## Setup

Add AWS access key to AWS CLI

```
aws configure
```

Add EKS cluster data to kubeconfig

```
aws eks update-kubeconfig --region eu-north-1 --name my-eks-cluster
```

Export cluster name

```
export cluster_name=my-eks-cluster
```

Fetch oidc id

```
oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
```

Associate oidc provider with cluster

```
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
```

Create IAM policy

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Assign IAM role to service account

```
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::<your-aws-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

Add helm repository

```
helm repo add eks https://aws.github.io/eks-charts
```

Update helm repository

```
helm repo update eks
```

Install ALB ingress controller

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=eu-north-1 \
  --set vpcId=<your-vpc-id>
```

## Illustrations

---
