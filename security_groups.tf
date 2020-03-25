
## Security group for myapp  instances
resource "aws_security_group" "myapp" {
  name        = "${var.app_prefix}-${var.env}"
  description = "${var.app_prefix} ${var.env} - Terraform managed"
  vpc_id      = "${aws_vpc.myapp.id}"
  tags = {
    Name      = "${var.app_prefix}-${var.env}"
  }

  # SSH access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${aws_vpc.myapp.cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
