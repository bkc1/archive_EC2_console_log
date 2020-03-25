resource "aws_iam_role" "lambda" {
  name               = "${var.app_prefix}-${var.env}-${var.aws_region}-LambdaServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_ec2" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.ec2_get_console.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.s3_put.arn}"
}

# Policy attached to LambdaServiceRole
resource "aws_iam_role_policy_attachment" "logs_policy" {
    role       = "${aws_iam_role.lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ec2_get_console" {
  name   = "${var.app_prefix}-${var.env}-${var.aws_region}-lambda-ec2"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:GetConsoleOutput",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3_put" {
  name   = "${var.app_prefix}-${var.env}-${var.aws_region}-lambda-s3"
  policy = "${data.template_file.s3_policy.rendered}"
}

# Template needed for dynamically create bucket name
data "template_file" "s3_policy" {
  template = "${file("${path.root}/templates/s3_policy.tpl")}"
  vars = {
    bucket = "${aws_s3_bucket.log.bucket}"
  }
}

# Zips the lamba source code for deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/src/"
  output_path = "${path.root}/dump-ec2-logs-s3.zip"
}

resource "aws_lambda_function" "lambda1" {
  filename         = "dump-ec2-logs-s3.zip"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "dump-ec2-logs-s3.lambda_handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "python3.8"
  timeout          = 12
  depends_on       = [aws_s3_bucket.log]
  environment {
    variables = {
      bucket = "${aws_s3_bucket.log.bucket}"
    }
  }
}

# Allow Cloudwatch to invoke Lamba
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda1.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_term.arn}"
}
