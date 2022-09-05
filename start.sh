#!/bin/bash

if [ -f "$(pwd)/.config" ]; then
    source "$(pwd)/.config"

    if [ -d "$LOCAL_PATH"/env/ ]; then
        source "$LOCAL_PATH/env/bin/activate"
    else
        # shellcheck disable=SC2091
        $(python3.9 -m venv "$LOCAL_PATH/env")
        source "$LOCAL_PATH/env/bin/activate"
    fi

    ################################################################
    TODAY=$(date +"%d%m%Y%H%I%S")
    DB_BACKUP_PATH="$LOCAL_PATH/backups/$(uname -n)"
    BACKUP_RETAIN_DAYS=1
    ################################################################

    # Check if $LOCAL_PATH/backups/$(uname -n) directory is not exists
    if [ ! -d "$LOCAL_PATH/backups/$(uname -n)" ]; then
        # shellcheck disable=SC2046
        mkdir -p "$LOCAL_PATH"/backups/$(uname -n)
    fi

    # get a list of databases
    databases=$(mysql --host="${MYSQL_HOST}" --user="${MYSQL_USER}" --password="${MYSQL_PASSWORD}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

    # Create folder
    mkdir "${DB_BACKUP_PATH}"/"${TODAY}"

    # backup all databases
    for DATABASE_NAME in $databases; do
        if [ "$DATABASE_NAME" != 'mysql' ] && [ "$DATABASE_NAME" != 'phpmyadmin' ] && [ "$DATABASE_NAME" != 'information_schema' ] && [ "$DATABASE_NAME" != 'performance_schema' ] && [ "$DATABASE_NAME" != 'test' ]; then
            echo "Backup started for database - ${DATABASE_NAME}"

            mysqldump -h "${MYSQL_HOST}" \
                -P "${MYSQL_PORT}" \
                -u "${MYSQL_USER}" \
                -p"${MYSQL_PASSWORD}" \
                "${DATABASE_NAME}" >"${DB_BACKUP_PATH}"/"${TODAY}"/"${DATABASE_NAME}"@"${MYSQL_HOST}"_"${TODAY}".sql

            # shellcheck disable=SC2181
            if [ $? -eq 0 ]; then
                echo "Database backup successfully completed"
            else
                echo "Error found during backup"
                exit 1
            fi
        fi
    done

    # compress backup folder
    cd "${DB_BACKUP_PATH}" && zip -r -qq "${TODAY}".zip "${TODAY}"

    # check compressing status
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        # shellcheck disable=SC2115
        rm -rf "${DB_BACKUP_PATH}"/"${TODAY}"
    else
        echo "Error found during backup"
        exit 1
    fi

    ##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
    find "${DB_BACKUP_PATH}" -name "*.zip" -type f -mtime +${BACKUP_RETAIN_DAYS} -exec rm -f {} \;

    # shellcheck disable=SC2164
    cd "$LOCAL_PATH"

    python -m pip install --upgrade pip
    pip install -r requirements.txt --quiet
    python "$LOCAL_PATH"/main.py

    echo "-------------------------------------"
    echo "Finished!"
else
    echo "Apps root folder must be in $(pwd) folder run install.sh or rename folder"
fi
