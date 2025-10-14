#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOGS_FOLDER="/var/log/mongodb"
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



dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs" 

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs 20" 

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs" 

id roboshop
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating a user" 
else
    echo -e "User already present $Y Skipping $Y"
fi
mkdir -p /app 
VALIDATE $? "Creating a app directory" 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  
VALIDATE $? "Downloading zip files" 

cd /app 
VALIDATE $? "Go to app directory" 

rm -rf /app/*
VALIDATE $? "removing the previous data"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping the contents" 

cd /app 
VALIDATE $? "go to app directory" 

npm install  &>>$LOG_FILE
VALIDATE $? "Installing node packages" 

cp $DIRECTORY/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Downloading client side mongodb" 

systemctl daemon-reload
VALIDATE $? "deamon reload" 

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabling the catalogue" 

systemctl start catalogue
VALIDATE $? "starting  the catalogue" 

cp $DIRECTORY/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying the mongo repo" 

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongo repo" 

mongosh --host $MONGODB_DOMAIN </app/db/master-data.js
VALIDATE $? "Connecting to mongo" 

systemctl restart catalogue
VALIDATE $? "restarting the catalogue" 