{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLambda",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${bucket}/*"
        }
    ]
}
