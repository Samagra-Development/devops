#!/bin/bash

#barman_password=password
#streaming_barman_password=password

# Prompt user for input
echo "Enter hostname/fqdn of postgres server:"
read host_name
echo "Enter database name to replicate wals:"
read db_name
echo "Enter password for barman user"
read barman_password
echo "Enter password for streaming_barman user"
read streaming_barman_password

echo "Entered hostname is $host_name and database name is $db_name"

### Function to confirm continuation
prompt_continue() {
    while true; do
        read -p "Do you want to continue? (yes/no): " yn
        case $yn in
            [Yy]* )
                echo "Continuing the script..."
                break
                ;;
            [Nn]* )
                echo "Exiting the script..."
                exit 0
                ;;
            * )
                echo "Please answer yes or no."
                ;;
        esac
    done
}
prompt_continue

### Update and install required packages if not already installed
echo "Updating package list..."
apt-get update
if ! dpkg -l | grep -qw curl; then
    echo "Installing curl..."
    apt-get install -y curl
else
    echo "curl is already installed, skipping........."
fi
if ! dpkg -l | grep -qw ca-certificates; then
    echo "Installing ca-certificates..."
    apt-get install -y ca-certificates
else
    echo "ca-certificates is already installed ,skipping.........."
fi
if ! dpkg -l | grep -qw gnupg; then
    echo "Installing gnupg..."
    apt-get install -y gnupg
else
    echo "gnupg is already installed, skipping ............."
fi

### Add PostgreSQL's authentication key if not already added
if ! apt-key list | grep -qw ACCC4CF8; then
    echo "Adding PostgreSQL's authentication key..."
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
else
    echo "PostgreSQL's authentication key already added, skippping..........."
fi

### Add PostgreSQL repository if not already added
if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
    echo "Adding PostgreSQL repository..."
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    apt-get update
else
    echo "PostgreSQL repository already added, skipping........."
fi

### Install barman if not already installed
if ! dpkg -l | grep -qw barman; then
    echo "Installing barman..."
    apt-get -y install barman
else
    echo "barman is already installed, skipping.........."
fi

# Create barman configuration file
config_file="/etc/barman.d/$host_name.conf"
if [ -e $config_file ]; then
    echo "Configuration file $config_file exists, deleting and recreating..."
    rm -f $config_file
else
    echo "Generating barman configuration file $config_file for streaming backup of database..."
fi

cat <<EOF > $config_file
[$host_name]
description = "Main PostgreSQL Database"
conninfo = host=$host_name user=barman dbname=$db_name password=$barman_password
ssh_command = ssh postgres@$host_name -p 2222
backup_method = rsync
parallel_jobs = 2
archiver = on
EOF

echo "Configuration file $config_file created."

### Create .pgpass file for barman user
barman_home=$(getent passwd barman | cut -d':' -f6)
pgpass_file="$barman_home/.pgpass"
if [ -e $pgpass_file ]; then
    echo "$pgpass_file exists, deleting and recreating..."
    rm -f $pgpass_file
else
    echo "Creating $pgpass_file for credentials..."
fi

sudo -u barman bash -c "echo '$host_name:5432:replication:barman:$barman_password' > ~/.pgpass"
sudo -u barman bash -c "echo '$host_name:5432:replication:streaming_barman:$streaming_barman_password' >> ~/.pgpass"
sudo -u barman bash -c "chmod 600 ~/.pgpass"
echo ".pgpass file created and permissions set."

:' ######## Commented key generation feature
### Deploying keys to barman
if [ -f ./id_rsa ]; then
        echo "Private key found deploying to barman user"
        mkdir -p $barman_home/.ssh/
        cp ./id_rsa $barman_home/.ssh/id_rsa
        cp ./id_rsa.pub $barman_home/.ssh/authorized_keys
        echo -e "Host *\n\tStrictHostKeyChecking no" > $barman_home/.ssh/config
        chmod 0600 $barman_home/.ssh/id_rsa
        echo "">$barman_home/.ssh/known_hosts
        chown -R barman:barman $barman_home/.ssh/
else
        echo "SSH keypair not found , please arrange key pair id_rsa , id_rsa.pub"
        echo "Rolling back insallation..........................................................."
        apt-get remove --purge barman -y
        apt-get autoremove -y
        exit
fi
### SSH deployment
'

### Set up barman cron job if not already set
if ! sudo crontab -u barman -l 2>/dev/null | grep -q "barman cron"; then
    echo "Setting up barman cron for receiving wals..."
    (sudo crontab -u barman -l 2>/dev/null; echo "* * * * * barman cron") | sudo crontab -u barman -
else
    echo "barman cron job already set."
fi
sleep 10s
### Create replication slot if not already created
if ! sudo -u barman barman show-server $host_name | grep -q "Slot name: $host_name"; then
    echo "Creating slot for receiving wals..."
    #sudo -u barman barman receive-wal --create-slot $host_name
else
    echo "Replication slot $host_name already exists."
fi

### Check the status of the db server
echo "Checking db server status..."
sleep 15s
sudo -u barman barman check $host_name

### Synchronize barman with postgres if necessary
echo "Synchronizing barman with postgresdb..."
sleep 5s

echo "Script execution completed."

