resource "aws_iam_role" "cwevent" {
  name               = "${var.app_prefix}-${var.env}-${var.aws_region}-CWevents"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["events.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "ec2_term" {
  name        = "${var.app_prefix}-${var.env}-${var.aws_region}-ec2-state-term"
  description = "Event based on ec2 termination"
  event_pattern = <<PATTERN
  {
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance State-change Notification"
  ],
  "detail": {
    "state": [
      "terminated"
    ]
  }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.ec2_term.name}"
  arn       = "${aws_lambda_function.lambda1.arn}"
}

# test json payload, for invoking lambda without actually terminating an instance
data "template_file" "test_event" {
  template = "${file("${path.root}/templates/test_event.tpl")}"
  vars = {
    region      = "${var.aws_region}"
    timestamp   = timestamp()
    instance_id = "${aws_instance.test1.id}"
    account_id  = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "local_file" "test_event" {
    content    = "${data.template_file.test_event.rendered}"
    filename   = "./test_event.json"
}
