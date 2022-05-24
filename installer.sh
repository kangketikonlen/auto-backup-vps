#!/bin/bash
# This script is used to install the application.
# This script should be executable.

# Save script directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3.9 &>/dev/null; then
	# Check linux distribution.
	. /etc/lsb-release
	if [ "$DISTRIB_ID" == "Ubuntu" ]; then
		# Change directory to home
		cd ~/
		# Install python3.9
		sudo apt update
		sudo apt install software-properties-common -y
		sudo add-apt-repository ppa:deadsnakes/ppa
		sudo apt install python3.9 python3.9-venv -y
		# Install pip
		wget -c https://bootstrap.pypa.io/get-pip.py
		python3.9 get-pip.py
		rm -rf get-pip.py
	else
		echo "Only Ubuntu is supported"
	fi
else
	echo "Python 3.9 is already installed"
fi

# Change directory to SCRIPT_DIR
cd "$SCRIPT_DIR"

# Check if .config file exists
if [ ! -f .config ]; then
	echo "File .config not found"
	# Create .config file
	touch .config

	# Ask for mysql host
	read -p "Enter mysql host: " MYSQL_HOST
	# Write MYQL_HOST to .config
	echo "MYSQL_HOST=$MYSQL_HOST" >>.config

	# Ask for mysql port
	read -p "Enter mysql port: " MYSQL_PORT
	# Write MYSQL_PORT to .config
	echo "MYSQL_PORT=$MYSQL_PORT" >>.config

	# Ask for mysql user
	read -p "Enter mysql user: " MYSQL_USER
	# Write MYSQL_USER to .config
	echo "MYSQL_USER=$MYSQL_USER" >>.config

	# Ask for mysql password
	read -p "Enter mysql password: " MYSQL_PASSWORD
	# Write MYSQL_PASSWORD to .config
	echo "MYSQL_PASSWORD=$MYSQL_PASSWORD" >>.config

	# Write LOCAL_PATH to .config
	echo "LOCAL_PATH=$(pwd)" >>.config
else
	echo "File .config found"
fi

# Get .credentials folder from remote server
scp -r -P 14045 akasakaryu@server.fathtech.co.id:/home/akasakaryu/.credentials ~/

# Get client_secret.json from remote server
scp -r -P 14045 akasakaryu@server.fathtech.co.id:/home/akasakaryu/scripts/client_secret.json .

# Check is Ubuntu
. /etc/lsb-release
if [ "$DISTRIB_ID" == "Ubuntu" ]; then
	# Write out current crontab
	crontab -l >mycron
	# echo new cron into cron file
	echo "0 5 * * * bash /home/akasakaryu/auto-backup-vps/start.sh > /home/akasakaryu/auto-backup-vps/logs/pagi.log" >>mycron
	# install new cron file
	crontab mycron
	rm mycron
else
	echo "Cronjob only Ubuntu is supported"
fi
