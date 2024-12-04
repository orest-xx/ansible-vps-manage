sudo apt update -y && sudo apt  upgrade -y 
sudo apt install curl git jq build-essential gcc unzip wget -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo apt-get install -y htop
sudo apt-get install expect -y  # For Ubuntu/Debian


#!/bin/bash

# Ensure both the node name and passphrase are provided
if [[ -z "$NODE_NAME" || -z "$PASSPHRASE" ]]; then
  echo "Usage: $0 <NODE_NAME> <PASSPHRASE>"
  exit 1
fi

# Create a temporary file to store the Sonaric install script
TEMP_SCRIPT="/tmp/sonaric_install.sh"

# Download the Sonaric install script
curl -fsSL http://get.sonaric.xyz/scripts/install.sh -o $TEMP_SCRIPT

# Create a temporary file to capture the output
OUTPUT_FILE="/tmp/sonaric_install_output.txt"

# Use spawn and expect to run the installation script
expect <<EOF > $OUTPUT_FILE
spawn bash $TEMP_SCRIPT

# Automatically respond to prompts
expect {
    "(?i)Do you want to change your Sonaric node name?" { send "y\r" }
    "(?i)The new NAME of the peer" { send "$NODE_NAME\r" }
    "(?i)Pick a secure passphrase to encrypt your identity file" { send "$PASSPHRASE\r" }
    "(?i)Confirm a secure passphrase" { send "$PASSPHRASE\r" }
}

# Wait for the script to finish
expect eof
EOF

# Capture the secret (JSON-like object) from the installation output
SECRET=$(grep -oP '\{[^}]+\}' $OUTPUT_FILE)

# Output the captured secret
echo "Captured Secret: $SECRET"

# Clean up temporary output file and script
rm -f $OUTPUT_FILE $TEMP_SCRIPT
