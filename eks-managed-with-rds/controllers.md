### Configure ALB Controller
```bash
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

# creat service account for pod identity
kubectl create sa aws-load-balancer-controller -n kube-system

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-mgd-cluster-1-33 \
  --set region=us-east-1 \
  --set vpcId=vpc-0b6c210477afe57b8 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.13.0

curl -H "Host: aknginx.com" http://k8s-myapp-ac4317dfb1-27931639.us-east-1.elb.amazonaws.com
curl -H "Host: akgame.com" http://k8s-myapp-ac4317dfb1-27931639.us-east-1.elb.amazonaws.com

helm uninstall aws-load-balancer-controller -n kube-system
```

### Configure Karpenter
```bash
export KARPENTER_NAMESPACE="kube-system"
export KARPENTER_VERSION="1.8.0"
export K8S_VERSION="1.33"

export AWS_PARTITION="aws" 
export CLUSTER_NAME="eks-mgd-cluster-1-33"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export TEMPOUT="$(mktemp)"
export ALIAS_VERSION="$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2023/x86_64/standard/recommended/image_id" --query Parameter.Value | xargs aws ec2 describe-images --query 'Images[0].Name' --image-ids | sed -r 's/^.*(v[[:digit:]]+).*$/\1/')"

```
With Feature Gates - will show warning
```bash
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "${KARPENTER_VERSION}" \
  --namespace "${KARPENTER_NAMESPACE}" \
  --create-namespace \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set replicas=1 \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=256Mi \
  --set controller.resources.limits.cpu=500m \
  --set controller.resources.limits.memory=512Mi \
  --set controller.env[0].name=FEATURE_GATES \
  --set controller.env[0].value="" \
  --timeout 10m \
  --wait

```

Default
```bash

aws sqs create-queue \
  --queue-name ${CLUSTER_NAME} \
  --attributes MessageRetentionPeriod=300

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "${KARPENTER_VERSION}" \
  --namespace kube-system \
  --create-namespace \
  --set "settings.clusterName=${CLUSTER_NAME}" \
  --set "settings.interruptionQueue=${CLUSTER_NAME}" \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi \
  --set "settings.featureGates.staticCapacity=false" \
  --timeout 10m \
  --wait

```

Reduced size
```bash
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "${KARPENTER_VERSION}" \
  --namespace kube-system \
  --create-namespace \
  --set "settings.clusterName=eks-mgd-cluster-1-33" \
  --set "settings.interruptionQueue=eks-mgd-cluster-1-33" \
  --set "settings.featureGates.staticCapacity=false" \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=256Mi \
  --set controller.resources.limits.cpu=500m \
  --set controller.resources.limits.memory=512Mi \
  --set replicas=1 \
  --timeout 10m \
  --wait

```