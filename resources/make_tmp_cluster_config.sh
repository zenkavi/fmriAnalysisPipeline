#! /bin/zsh
alias aws='docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'
export REGION=`aws configure get region`
export SUBNET_ID=`aws ec2 describe-subnets | jq -j '.Subnets[0].SubnetId'`
export VPC_ID=`aws ec2 describe-vpcs | jq -j '.Vpcs[0].VpcId'`

cat > tmp.yaml << EOF

HeadNode:
  CustomActions:
    OnNodeConfigured:
      Script: s3://zenkavi/head-node-setup-env.sh
  Iam:
    S3Access:
      - BucketName: zenkavi
        EnableWriteAccess: True
Scheduling:
  Scheduler: slurm
  SlurmQueues:
    - Name: queue1
      CustomActions:
        OnNodeConfigured:
          Script: s3://zenkavi/compute-node-setup-env.sh
      Iam:
        S3Access:
          - BucketName: zenkavi
            EnableWriteAccess: True

Iam:
  AdditionalIamPolicies:
    - Policy: arn:aws:iam::aws:policy/AmazonS3FullAccess


EOF
