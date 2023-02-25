# Automated Selection of Leader Instances in an Autoscaling Group

This project creates an infrastructure for automated selection of leader instances in an autoscaling group using Terraform or CloudFormation. The project consists of a Lambda function, which automatically selects a leader instance based on a predetermined algorithm, and a set of Terraform or CloudFormation templates that deploy the necessary resources.

## Prerequisites
Before deploying the infrastructure, make sure you have the following prerequisites in place:

- An AWS account with sufficient permissions to create IAM roles, Lambda functions, and Autoscaling groups.
- Terraform 0.12+ or AWS CLI installed on your local machine, depending on which deployment method you choose.
- Basic knowledge of AWS services and either Terraform or CloudFormation.

## Folder Structure
The project is organized into the following directory structure:

```
.
├── README-terraform.md
├── README.md
├── cloudformation
│   └── elect-leader-asg.yaml
├── lambda
│   └── index.py
├── main.tf
└── variables.tf
```

- `README-terraform.md`: A readme file specific to Terraform.
- `README.md`: This readme file.
- `cloudformation`: A directory containing CloudFormation templates.
- `lambda`: A directory containing the Lambda function code.
- `main.tf`: The main Terraform file.
- `variables.tf`: The Terraform variables file.

## Setup

### Step 1: Deploy the Infrastructure
#### Terraform
1. Navigate to the root directory.
2. Edit the variables.tf file to include your custom values for the Terraform variables.
3. Run the following command to initialize Terraform:
```
terraform init
```
4. Run the following command to deploy the infrastructure:
```
terraform apply
```
5. Enter `yes` when prompted to confirm the deployment.
6. This should setup the necessary resources in your AWS account.

#### CloudFormation
1. Navigate to the cloudformation directory.
2. Edit the elect-leader-asg.yaml file to include your custom values for the CloudFormation parameters.
3. Run the following command to deploy the CloudFormation stack:
```
aws cloudformation create-stack --stack-name elect-leader-asg --template-body file://./elect-leader-asg.yaml --capabilities CAPABILITY_IAM
```
4. This should setup the necessary resources in your AWS account.
5. You can also upload the elect-leader-asg.yaml file to the CloudFormation console and deploy it from there.

### Step 2: Verify the Deployment
1. Once the deployment is complete, navigate to the AWS Management Console and check that the resources have been created.
2. Monitor the leader selection process by checking the logs of the Lambda function.
3. Verify that the selected leader instance is handling the expected tasks.

## Conclusion
This project should help you create an infrastructure for automated selection of leader instances in an autoscaling group using either Terraform or CloudFormation. Remember to always follow AWS best practices for security and cost optimization.

## References
- [Leader Instances in AWS Auto Scaling Groups](https://ajbrown.org/2017/02/10/leader-election-with-aws-auto-scaling-groups.html)
