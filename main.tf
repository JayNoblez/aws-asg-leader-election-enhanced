# Leader election automatically determines a "leader" instance within an autoscaling
# group.  Scaling events will trigger leader election, insuring there is always one
# leader whenever instances are added or removed.

provider "aws" {
  region = "us-east-1"
}

locals {
  lambda_path = "${path.module}/lambda"
}

data "archive_file" "packaged_lambda" {
  type        = "zip"
  source_dir  = local.lambda_path
  output_path = "${path.module}/${random_uuid.lambda_src_hash.result}.zip"
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_path, "*.py")
    ) :
    filename => filemd5("${local.lambda_path}/${filename}")
  }
}

resource "aws_cloudwatch_event_rule" "scaling_event_rule" {
  name        = "scaling_event_rule"
  description = "Rule for scaling event in elastic beanstalk"
  event_pattern = jsonencode({
    source      = ["aws.autoscaling"]
    detail_type = ["EC2 Instance Launch Successful", "EC2 Instance Terminate Successful", "EC2 Instance Launch Unsuccessful", "EC2 Instance Terminate Unsuccessful", "EC2 Instance-launch Lifecycle Action", "EC2 Instance-terminate Lifecycle Action"]
    detail      = {
      AutoScalingGroupName = [{ prefix = var.asg_name_prefix }]
    }
  })
}

resource "aws_lambda_function" "leader" {
  filename      = data.archive_file.packaged_lambda.output_path
  function_name = var.name
  description   = "Elects a leader in an autoscaling upon receiving scaling events"
  role          = aws_iam_role.lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30

  source_code_hash = data.archive_file.packaged_lambda.output_base64sha256
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.scaling_event_rule.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.leader.arn
}

resource "aws_lambda_permission" "eventBridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.leader.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scaling_event_rule.arn
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.name}-lambda-role-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:Describe*", "ec2:*Tags"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Action   = ["ec2:DescribeAvailabilityZones", "ec2:DescribeInstances", "autoscaling:DescribeAutoScalingGroups", "autoscaling:DescribeAutoScalingInstances", "autoscaling:DescribeTags", "s3:ListMyBuckets"]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}
