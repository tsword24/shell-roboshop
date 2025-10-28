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
DIRECTORY=$PWD
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

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx" 

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx" 

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "INstalling nginx" 

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enabling nodejs" 

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "starting nginx " 

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "remove  files of nginx" 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "copying files of nginx" 

cd /usr/share/nginx/html &>>$LOG_FILE

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping nginx" 

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "remopving nginx conf " 

cp $DIRECTORY/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "copying nginx files" 

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restarting nginx" 