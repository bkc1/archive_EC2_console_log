
# S3 resources

resource "random_id" "hash" {
  byte_length = 4
}

# S3 bucket gets removed upon terraform destroy
resource "aws_s3_bucket" "log" {
  bucket        = "ec2-console-logs-${random_id.hash.hex}"
  force_destroy = true
}
