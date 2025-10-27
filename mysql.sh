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


dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enable mysql"

systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "Starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Create user with Password"