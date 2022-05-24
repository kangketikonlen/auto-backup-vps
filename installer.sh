#!/bin/bash
# This script is used to install the application.
# This script should be executable.

# Save script directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3.9 &>/dev/null; then
	echo "Python 3.9 is not installed."
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
		exit 1
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

# Ask user if he wants to automatically get credentials from another server
read -p "Do you want to get credentials from another server? [y/n]: " GET_CREDENTIALS
# If user wants to get credentials from another server
if [ "$GET_CREDENTIALS" == "y" ]; then
	# Ask user ssh port
	read -p "Enter ssh port: " SSH_PORT
	# Ask user ssh user
	read -p "Enter ssh user: " SSH_USER
	# Ask user ip/domain of server
	read -p "Enter ip/domain of server: " SERVER_IP
	# Ask user the directory of credentials
	read -p "Enter the directory of credentials: " CREDENTIALS_DIR
	# Get .credentials folder from remote server
	scp -r -P $SSH_PORT $SSH_USER@$SERVER_IP:$CREDENTIALS_DIR ~/
fi

# ASk user if he wants to automatically get client_secret.json from another server
read -p "Do you want to get client_secret.json from another server? [y/n]: " GET_CLIENT_SECRET
# If user wants to get client_secret.json from another server
if [ "$GET_CLIENT_SECRET" == "y" ]; then
	# Change directory to SCRIPT_DIR
	cd "$SCRIPT_DIR"
	# Ask user ssh port
	read -p "Enter ssh port: " SSH_PORT
	# Ask user ssh user
	read -p "Enter ssh user: " SSH_USER
	# Ask user ip/domain of server
	read -p "Enter ip/domain of server: " SERVER_IP
	# Ask user the directory of client_secret.json
	read -p "Enter the directory of client_secret.json: " CLIENT_SECRET_DIR
	# Get client_secret.json from remote server
	scp -r -P $SSH_PORT $SSH_USER@$SERVER_IP:$CLIENT_SECRET_DIR .
fi

# Check is Ubuntu
. /etc/lsb-release
if [ "$DISTRIB_ID" == "Ubuntu" ]; then
	# Write out current crontab
	crontab -l >mycron
	# echo new cron into cron file
	echo "0 5 * * * bash $SCRIPT_DIR/start.sh > $SCRIPT_DIR/logs/pagi.log" >>mycron
	# install new cron file
	crontab mycron
	rm mycron
else
	echo "Cronjob only Ubuntu is supported"
fi

# Ask user if he wants to start the application now
read -p "Do you want to start the application now? [y/n]: " START_NOW
# If user wants to start the application now
if [ "$START_NOW" == "y" ]; then
	# Change directory to SCRIPT_DIR
	cd "$SCRIPT_DIR"
	# Start the application
	bash start.sh
fi
