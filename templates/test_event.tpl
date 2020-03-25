{
   "id":"7bf73129-1428-4cd3-a780-000000000000",
   "detail-type":"EC2 Instance State-change Notification",
   "source":"aws.ec2",
   "account":"${account_id}",
   "time":"${timestamp}",
   "region":"${region}",
   "resources":[
      "arn:aws:ec2:${region}:${account_id}:instance/${instance_id}"
   ],
   "detail":{
      "instance-id":"${instance_id}",
      "state":"terminated"
   }
}
