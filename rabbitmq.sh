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

cp $SCRIPT_DIRECTORY/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copying rabbitmq repo"

dnf install rabbitmq-server -y  &>>$LOG_FILE
VALIDATE $? "INstalling rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enable rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Start rabbitmq server"

rabbitmqctl add_user roboshop roboshop123  &>>$LOG_FILE
VALIDATE $? "Adding user in  rabbitmq server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Setting permissions in  rabbitmq server"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "Script executed in : $Y $TOTAL_TIME $N"