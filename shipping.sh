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


dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating user"

mkdir -p /app 

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Geting dependicies"

cd /app 
VALIDATE $? "Going to app directory"

rm -rf /app/*  &>>$LOG_FILE
VALIDATE $? "Removing previous files from app directory"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping files from shipping "

cd /app 
VALIDATE $? "going to app directory"

mvn clean package  &>>$LOG_FILE
VALIDATE $? "Maven cleaning package"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Maven"

cp $SCRIPT_DIRECTORY/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Shipping service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon reload"

systemctl enable shipping  &>>$LOG_FILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_DOMAIN -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ];then
    mysql -h $MYSQL_DOMAIN -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_DOMAIN -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h $MYSQL_DOMAIN -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data already loaded $Y Skipping $N"
fi

systemctl restart shipping
VALIDATE $? "Restart Shipping"