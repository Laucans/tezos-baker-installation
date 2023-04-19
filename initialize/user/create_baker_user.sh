#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <user>"
  exit 1
fi

# Create a new non-root user for the Tezos baker
if ! id -u $1 >/dev/null 2>&1; then
  sudo adduser --disabled-password --gecos "" $1
  echo "Created user '$1'"

  # Prompt user to change the password for the new user
  echo "Please enter a new password for user '$1'"
  sudo passwd $1
fi

# Create the working directory for the Tezos baker
if [ ! -d "/home/$1" ]; then
  sudo mkdir -p /home/$1
  echo "Created directory '/home/$1'"
fi

# Change the owner of the working directory to the new user
sudo chown -R $1:$1 /home/$1
echo "Changed owner of '/home/$1' to user '$1'"

# Give the new user read and write permissions to the working directory
sudo chmod -R u+rw /home/$1
echo "Granted read and write permissions to user '$1' on '/home/$1'"

# Give the new user execute permissions to the working directory
sudo chmod -R u+x /home/$1
echo "Granted execute permissions to user '$1' on '/home/$1'"

# Add SSH access for users with SSH access to the user running the script to the new user
if [ ! -d "/home/$1/.ssh" ]; then
  sudo mkdir -p /home/$1/.ssh
  sudo cp ~/.ssh/authorized_keys /home/$1/.ssh/
  sudo chown -R $1:$1 /home/$1/.ssh
  sudo chmod 700 /home/$1/.ssh
  sudo chmod 600 /home/$1/.ssh/authorized_keys
  echo "Added SSH access for users with SSH access to the user '$1'"
fi

# Restart the SSH service
sudo systemctl restart ssh
echo "SSH service restarted"

# Add user to plugdev group to be able to interact with ledger
sudo usermod -a -G plugdev $1
