# Terraform - Dump EC2 system console logs to S3 upon termination

## Overview

This is intended to be a demo/example project that uses Cloudwatch Events and Lamba to automatically dump EC2 console logs to an S3 bucket. EC2 console logs are only available for about 1 hour after an instance is terminated. Capturing these logs can be useful in troubleshooting issues on workloads that programmatically start/terminate EC2 instances and AWS services that utilize EC2(i.e. EMR, ECS and EKS).

Terraform creates an EC2 instance for the purpose of demonstrating how the lambda function automatically gets triggered by cloudwatch events when it's state changes to `terminated`.

A few additional notes:
- Terraform will zip up the python source before deploying the Lambda function
- Terraform will create a test JSON payload(called `test_event.json`) from a template to allow testing the lambda without actually terminating the instance. See testing info below.


## Prereqs & Dependencies

This was developed and tested with Terraform v0.12.23 and AWS-cli v2.0.4. The Lambda function is using the Python3.8 runtime and Boto3 SDK.

An AWS-cli configuration with elevated IAM permissions must be in place. The IAM access and secret keys in the AWS-cli are needed by Terraform in this example.

In order for the EC2 instance to launch successfully, you must first create an SSH key pair in the 'keys' directory named `mykey`.

```
ssh-keygen -t rsa -f ./keys/mykey -N ""
```


## Usage

Set the desired AWS region and change any default variables in the `variables.tf` file.

### Deploying with Terraform
```
terraform init  ## initialize Teraform
terraform plan  ## Review what terraform will do
terraform apply ## Deploy the resources
```
Tear-down the resources in the stack
```
$ terraform destroy
```
### Terminate EC2 instance to trigger Lambda

After the stack is successfully deployed via terraform, note the terraform outputs which are needed for the AWScli commands below:
```
$ aws ec2 terminate-instances --instance-ids <instanceid> --region <region>
```
Run `terraform apply` again to launch a new instance and repeat.

### Testing the Lamba without terminating an EC2 instance
Note that the `--cli-binary-format raw-in-base64-out` parameter is needed for AWScli v2.
```
$ aws lambda invoke --function dump-ec2-logs-s3 --region <region> --payload file://test_event.json --cli-binary-format raw-in-base64-out out.txt
```
