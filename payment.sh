#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME="$( echo $0 | cut -d "." -f1)" #to get the script name
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_DOMAIN="mongodb.ssnationals.fun"
MYSQL_DOMAIN="mysql.ssnationals.fun"
SCRIPT_DIRECTORY=$PWD
START_TIME=$(date +%s)
mkdir -p $LOGS_FOLDER
echo "Script Started at $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then 
    echo "Give root privilages"
    exit 1
fi

VALIDATE(){
    if [ $1 -eq 0 ];then
        echo -e " $2 $G success$N"  | tee -a $LOG_FILE
    else
        echo -e " $2 $R Failure$N" | tee -a $LOG_FILE
        exit 1 
    fi
}

dnf install python3 gcc python3-devel -y  &>>$LOG_FILE

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating user"

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Geting dependicies"

cd /app 
VALIDATE $? "Going to app directory"

rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "Removing previous files from app directory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping files from payment "

cd /app 
VALIDATE $? "going to app directory"

pip3 install -r requirements.txt &>>$LOG_FILE


cp $SCRIPT_DIRECTORY/payment.service /etc/systemd/system/payment.service
VALIDATE $? "payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon reload"

systemctl enable payment  &>>$LOG_FILE
VALIDATE $? "Enabling payment service"

systemctl start payment
VALIDATE $? "Starting payment service"

systemctl restart payment
VALIDATE $? "Restart payment"