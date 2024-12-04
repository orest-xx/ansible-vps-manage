#!/bin/bash

sudo apt update -y && sudo apt  upgrade -y 
sudo apt install curl git jq build-essential gcc unzip wget -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo apt-get install -y htop
sudo apt-get install expect -y  # For Ubuntu/Debian

# Validate that correct number of arguments are supplied
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <NODE_NAME> <PASSPHRASE>"
  exit 1
fi

NODE_NAME="$1"
PASSPHRASE="$2"

# Provide necessary inputs during the script execution process
installation_output=$(sh -c "$(curl -fsSL http://get.sonaric.xyz/scripts/install.sh)" <<EOF
y
$NODE_NAME
$PASSPHRASE
$PASSPHRASE
EOF
)

# Debugging - Print the raw output
echo "Installation output captured:"
echo "$installation_output"

# Extract the secret part of the output
# Suppose this output is identifiable and consistent with ^{PublicID:
secret=$(echo "$installation_output" | grep -oP '\{[^}]+\}' | tail -1)

# Check and output the right secret
if [[ -n "$secret" ]]; then
  echo "SecretCaptured: $secret"
else
  echo "Failed to capture the secret."
fi