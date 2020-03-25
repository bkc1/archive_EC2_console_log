output "ec_instance_pubip"       { value = "${aws_instance.test1.public_ip}"}
output "ec2_instance_id"        { value = "${aws_instance.test1.id}"}
output "lambda_name"            { value = "${aws_lambda_function.lambda1.function_name}"}
