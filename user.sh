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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs server"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs server"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs server"

id roboshop
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating a user" 
else
    echo -e "User already present $Y Skipping $Y"
fi

mkdir /app 
VALIDATE $? "Make app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "get the item from online"

cd /app 
VALIDATE $? "go to app directory"

rm -rf /app/*
VALIDATE $? "remove app directory"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unzip the files"

cd /app 
VALIDATE $? "go to app directory"

npm install  &>>$LOG_FILE
VALIDATE $? "node package manager"

cp $DIRECTORY/user.service  /etc/systemd/system/user.service
VALIDATE $? "enabel user service"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user service"

systemctl start user
VALIDATE $? "Start user service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "Script executed in : $Y $TOTAL_TIME $N"