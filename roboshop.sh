#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0a97a62e138263506"

for instances in $@
do
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instances}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance != "frontend" ];then
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
else
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
fi
echo "$instance:$IP"
done