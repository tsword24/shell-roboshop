#!/bin/bash

for instances in $@
do
INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0a97a62e138263506 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instances}]" --query 'Instances[0].InstanceId' --output text)

if [ $INSTANCE_ID -eq "frontend" ];then
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
else
IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
fi

done