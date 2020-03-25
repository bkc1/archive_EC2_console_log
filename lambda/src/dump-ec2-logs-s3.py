import boto3
import os

def lambda_handler(event, context):
    region = event['region']
    instanceid = event['detail']['instance-id']
    logbucket = os.environ['bucket']


    # Get EC2 console log
    ec2_client = boto3.client('ec2',region_name=region)
    response = ec2_client.get_console_output(InstanceId=instanceid)

    # Capture only output section of response
    output = str(response["Output"])
    #print(output)


    #Write output to object in S3
    s3_client = boto3.client('s3', region_name=region)
    s3object = s3_client.put_object(
      Bucket=logbucket,
      Key=(instanceid) + '_console.log',
      Body=output
    )

    print('-----EC2 system console log dumped to s3://' + (logbucket) + '/' + (instanceid) + '_console.log')
