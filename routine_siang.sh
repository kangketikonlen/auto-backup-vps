#!/bin/bash

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%m%Y%H%I%S"`

################################################################
################## Update below values  ########################
DB_BACKUP_PATH='/home/akasakaryu/backups/siang'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='fath_dev'
MYSQL_PASSWORD='fathtech123'
BACKUP_RETAIN_DAYS=3
#################################################################

# get a list of databases
databases=`mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} \
-e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

# Create folder
mkdir ${DB_BACKUP_PATH}/${TODAY}

# backup all databases
for DATABASE_NAME in $databases; do
    if [ $DATABASE_NAME != 'mysql' ] && [ $DATABASE_NAME != 'phpmyadmin' ] && [ $DATABASE_NAME != 'information_schema' ] && [ $DATABASE_NAME != 'performance_schema' ] && [ $DATABASE_NAME != 'test' ]
    then
        echo "Backup started for database - ${DATABASE_NAME}"

        mysqldump -h ${MYSQL_HOST} \
        -P ${MYSQL_PORT} \
        -u ${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        ${DATABASE_NAME} > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}@${MYSQL_HOST}_${TODAY}.sql

        if [ $? -eq 0 ]; then
            echo "Database backup successfully completed"
        else
            echo "Error found during backup"
            exit 1
        fi
    fi
done

# compress backup folder
zip -r ${DB_BACKUP_PATH}/${TODAY}.zip ${DB_BACKUP_PATH}/${TODAY}/

# check compressing status
if [ $? -eq 0 ]; then
    rm -rf ${DB_BACKUP_PATH}/${TODAY}
else
    echo "Error found during backup"
    exit 1
fi

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
find ${DB_BACKUP_PATH} -name "*.zip" -type f -mtime +${BACKUP_RETAIN_DAYS} -exec rm -f {} \;

echo -------------------------------------
echo   Finished!
