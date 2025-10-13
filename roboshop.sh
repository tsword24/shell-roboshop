#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0a97a62e138263506"
ZONE_ID="Z02343572Y2FGSE24I49V"
DOMAIN_NAME="ssnationals.fun"

for instances in $@
do
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instances}]" --query 'Instances[0].InstanceId' --output text)

if [ $instances != "frontend" ];then
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
RECORD_ID="$instances.$DOMAIN_NAME"
else
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
RECORD_ID="$DOMAIN_NAME"
fi
echo "$instances:$IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID\
    --change-batch '
    {
        "Comment": "Creating a test A record",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$RECORD_ID'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                        {
                            "Value": "'$IP'"
                        }
                    ]
                }
            }
        ]
    }'


done