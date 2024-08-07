#!/bin/bash

# Environment check
read -p "Enter the current Docker volume name: " current_volume_name
if [[ -z $current_volume_name ]]; then
  echo "Error: Current Docker volume name cannot be blank."
  exit 1
fi

read -p "Enter the source host address (e.g., localhost): " SOURCE_HOST_ADDRESS
if [[ -z $SOURCE_HOST_ADDRESS ]]; then
  echo "Error: Source host address cannot be blank."
  exit 1
fi

read -p "Enter the source host user (e.g., $USER): " SOURCE_HOST_USER
if [[ -z $SOURCE_HOST_USER ]]; then
  echo "Error: Source host user cannot be blank."
  exit 1
fi

read -p "Enter the new Docker volume name: " new_volume_name
if [[ -z $new_volume_name ]]; then
  echo "Error: New Docker volume name cannot be blank."
  exit 1
fi

read -p "Enter the target host address (e.g., 3.111.186.64): " TARGET_HOST_ADDRESS
if [[ -z $TARGET_HOST_ADDRESS ]]; then
  echo "Error: Target host address cannot be blank."
  exit 1
fi

read -p "Enter the target host user (e.g., ubuntu): " TARGET_HOST_USER
if [[ -z $TARGET_HOST_USER ]]; then
  echo "Error: Target host user cannot be blank."
  exit 1
fi

if [[ $SOURCE_HOST_ADDRESS != $TARGET_HOST_ADDRESS ]]; then
  read -p "Enter the path to your SSH private key file: " SSH_PRIVATE_KEY_FILE
  if [[ -z $SSH_PRIVATE_KEY_FILE ]]; then
    echo "Error: Path to SSH private key file cannot be blank."
    exit 1
  fi
fi
echo "------------------------------------------------------------------------------"


# Export the volume from the host machine
echo "Exporting volume $current_volume_name from local machine"
mkdir -p $HOME/docker-volume-backup
docker run \
  --rm \
  -v $current_volume_name:/volume-backup-source \
  -v $HOME/docker-volume-backup:/volume-backup-target \
  busybox \
  sh -c 'cd /volume-backup-source && tar cf /volume-backup-target/backup.tar .' \

if [[ $? -eq 0 ]]; then
  echo "Volume export of $current_volume_name successful"
else
  echo "Volume export of $current_volume_name failed"
  exit 1
fi



# Verify if Source and target are same
if [[ $SOURCE_HOST_ADDRESS == $TARGET_HOST_ADDRESS ]]; then
  echo "Source and target addresses are the same. Migrating within the same machine."
  echo "Creating volume $new_volume_name"
  
  docker volume create $new_volume_name
  if [[ $? -eq 0 ]]; then
    echo "Volume $new_volume_name created successfully"
  else
    echo "Failed to create volume $new_volume_name"
    exit 1
  fi

  echo "Restoring backup to volume $new_volume_name"
  docker run \
    --rm \
    -v $new_volume_name:/volume-backup-target \
    -v $HOME/docker-volume-backup:/volume-backup-source \
    busybox \
    sh -c 'cd /volume-backup-target && tar xf /volume-backup-source/backup.tar .' \

    if [[ $? -eq 0 ]]; then
    echo "Backup restored to volume $new_volume_name successfully"
  else
    echo "Failed to restore backup to volume $new_volume_name"
    exit 1
  fi
  
  echo "Cleaning up unnecessary files"
  sudo rm -rf $HOME/docker-volume-backup

else
  # Transfer the exported volume to the new address
  echo "Transferring exported volume $current_volume_name from local machine to $TARGET_HOST_ADDRESS"
  ssh -i "$SSH_PRIVATE_KEY_FILE" "$TARGET_HOST_USER@$TARGET_HOST_ADDRESS" << 'EOF' > /dev/null 2>&1
mkdir -p $HOME/docker-volume-backup
EOF
  scp -i "$SSH_PRIVATE_KEY_FILE" "$HOME/docker-volume-backup/backup.tar" \
    "$TARGET_HOST_USER@$TARGET_HOST_ADDRESS:/home/$TARGET_HOST_USER/docker-volume-backup/backup.tar" > /dev/null 2>&1


  if [[ $? -eq 0 ]]; then
    echo "Transfer of volume $current_volume_name to $TARGET_HOST_ADDRESS successful"
  else
    echo "Transfer of volume $current_volume_name to $TARGET_HOST_ADDRESS failed"
    exit 1
  fi

  # Restore the backup
  echo "Creating volume $new_volume_name on $TARGET_HOST_ADDRESS"
  echo "Restoring backup"
  ssh -i "../../Downloads/migrate_volume.pem" "$TARGET_HOST_USER@$TARGET_HOST_ADDRESS" "\
  docker volume create $new_volume_name \
  && docker run \
    --rm \
    -v $new_volume_name:/volume-backup-target \
    -v \$HOME/docker-volume-backup/:/volume-backup-source \
    busybox \
    sh -c 'cd /volume-backup-target && tar xf /volume-backup-source/backup.tar .' \
  " > /dev/null 2>&1

  if [[ $? -eq 0 ]]; then
    echo "Volume $new_volume_name created and backup restored successfully on $TARGET_HOST_ADDRESS"
  else
    echo "Volume creation or backup restoration on $TARGET_HOST_ADDRESS failed"
    exit 1
  fi

  # Clean up residual files
  echo "Cleaning up unnecessary files"
  sudo rm -rf $HOME/docker-volume-backup
  ssh -i "$SSH_PRIVATE_KEY_FILE" "$TARGET_HOST_USER@$TARGET_HOST_ADDRESS" << EOF > /dev/null 2>&1
  rm -rf \$HOME/docker-volume-backup
EOF

fi

echo "Successfully migrated docker volume $volume_name from $SOURCE_HOST_ADDRESS to $TARGET_HOST_ADDRESS"