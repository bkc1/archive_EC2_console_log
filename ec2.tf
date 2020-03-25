
# test/demo instance to trigger a cloudwatch event
resource "aws_instance" "test1" {
  tags                    = {
    Name                  = "${var.app_prefix}-${var.env}-test1"
  }
  instance_type           = "t2.micro"
  ami                     = "${data.aws_ami.amznlinux2.id}"
  key_name                = "${aws_key_pair.auth.id}"
  vpc_security_group_ids  = ["${aws_security_group.myapp.id}"]
  subnet_id               = "${aws_subnet.myapp1.id}"
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
}
