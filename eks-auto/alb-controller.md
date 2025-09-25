
```bash
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-auto-cluster-1-33 \
  --set region=us-east-1 \
  --set vpcId=vpc-040e5372378485dd2 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.13.0

curl -H "Host: aknginx.com" http://k8s-myapp-ac4317dfb1-27931639.us-east-1.elb.amazonaws.com
curl -H "Host: akgame.com" http://k8s-myapp-ac4317dfb1-27931639.us-east-1.elb.amazonaws.com

helm uninstall aws-load-balancer-controller -n kube-system
```