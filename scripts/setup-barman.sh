#!/bin/bash

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

cat <<EOF > /etc/barman.conf
[barman]
barman_home = /backup/barman
barman_user = barman
log_file = /var/log/barman/barman.log
compression = gzip
reuse_backup = link
backup_method = rsync
archiver = on
EOF

cat <<EOF > $config_file
[$host_name]
description = "Main PostgreSQL Database"
conninfo = host=$host_name user=barman dbname=$db_name password=$barman_password
ssh_command = ssh -q postgres@$host_name -p 2222
retention_policy_mode = auto
retention_policy = RECOVERY WINDOW OF 7 days
wal_retention_policy = main
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


echo "Barman Installation Completed"
