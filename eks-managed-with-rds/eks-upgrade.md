
Get eks optimized AMI
```bash
aws ssm get-parameter \
  --name /aws/service/eks/optimized-ami/1.33/amazon-linux-2023/x86_64/standard/recommended/image_id \
  --region us-east-1 \
  --query "Parameter.Value" \
  --output text

  aws ssm get-parameters-by-path \
  --path /aws/service/eks/optimized-ami/1.33/amazon-linux-2023/x86_64/standard/ \
  --region us-east-1 \
  --query 'Parameters[].Name' \
  --output text
```