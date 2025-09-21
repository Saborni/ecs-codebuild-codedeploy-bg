#!/bin/bash

# Deployment script for the three-tier CloudFormation templates
# Usage: ./deploy.sh [stack-prefix] [region]

STACK_PREFIX=${1:-"ecs-blue-green"}
REGION=${2:-"us-east-1"}

echo "Deploying CloudFormation stacks with prefix: $STACK_PREFIX in region: $REGION"

# Deploy VPC and ALB stack first
echo "1. Deploying VPC and ALB infrastructure..."
aws cloudformation deploy \
  --template-file 0-vpc-alb-template.yaml \
  --stack-name "${STACK_PREFIX}-vpc-alb" \
  --region $REGION \
  --capabilities CAPABILITY_IAM

if [ $? -ne 0 ]; then
  echo "Failed to deploy VPC and ALB stack"
  exit 1
fi

# Deploy ECS Fargate application
echo "2. Deploying ECS Fargate application..."
aws cloudformation deploy \
  --template-file 1-ecs-fargate-template.yaml \
  --stack-name "${STACK_PREFIX}-ecs-app" \
  --region $REGION \
  --capabilities CAPABILITY_IAM \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides VpcStackName="${STACK_PREFIX}-vpc-alb" MonitoringStackName="${STACK_PREFIX}-monitoring"  

if [ $? -ne 0 ]; then
  echo "Failed to deploy ECS application stack"
  exit 1
fi

echo "All stacks deployed successfully!"
echo "VPC Stack: ${STACK_PREFIX}-vpc-alb"
echo "ECS Stack: ${STACK_PREFIX}-ecs-app"