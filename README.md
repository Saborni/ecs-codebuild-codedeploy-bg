# ECS Blue/Green Deployment with CodeBuild and CodeDeploy

A proof-of-concept demonstrating blue/green deployments for containerized applications using AWS ECS Fargate, CodeBuild, and CodeDeploy.

## Architecture

- **Flask Application**: Simple web app with health check endpoint
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: Traffic routing with blue/green target groups
- **VPC**: Isolated network with public/private subnets and VPC endpoints
- **CloudFormation**: Infrastructure as Code for reproducible deployments

## Project Structure

```
├── infra/
│   ├── 0-vpc-alb-template.yaml    # VPC, subnets, ALB, target groups
│   ├── 1-ecs-fargate-template.yaml # ECS cluster, service, task definition
│   └── deploy-infra.sh            # Deployment script
├── lnews-app/
│   ├── app.py                     # Flask application
│   ├── Dockerfile                 # Container image definition
│   ├── requirements.txt           # Python dependencies
│   └── templates/index.html       # Web template
└── LICENSE
```

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Docker (for local testing)

### Deploy Infrastructure

```bash
cd infra
./deploy-infra.sh [stack-prefix] [region]
```

Default values:
- Stack prefix: `ecs-blue-green`
- Region: `us-east-1`

### Build and Test Application Locally

```bash
cd lnews-app
docker build -t lnews-app .
docker run -p 5000:5000 lnews-app
```

Access the application at `http://localhost:5000`

## Infrastructure Components

### VPC Stack (`0-vpc-alb-template.yaml`)
- VPC with public/private subnets across 2 AZs
- Internet Gateway and NAT Gateway
- VPC Endpoints for ECR, S3, CloudWatch Logs
- Application Load Balancer with blue/green target groups
- Security groups for ALB and VPC endpoints

### ECS Stack (`1-ecs-fargate-template.yaml`)
- ECS Fargate cluster
- Task definition with Flask container
- ECS service with load balancer integration
- IAM roles for task execution
- CloudWatch log group

## Application Details

The Flask application provides:
- `/` - Main page rendering HTML template
- `/health` - Health check endpoint returning JSON status

## Configuration

Key parameters in CloudFormation templates:
- `ContainerImage`: ECR image URI for the application
- `VpcCIDR`: VPC CIDR block (default: 10.100.0.0/16)
- `AvailabilityZones`: AZs for subnet placement

## Cleanup

Delete CloudFormation stacks in reverse order:
```bash
aws cloudformation delete-stack --stack-name ecs-blue-green-ecs-app
aws cloudformation delete-stack --stack-name ecs-blue-green-vpc-alb
```

## License

Apache License 2.0