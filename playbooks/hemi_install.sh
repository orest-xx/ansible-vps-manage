#!/bin/bash
sudo apt update -y
sudo apt install mc wget curl git htop netcat net-tools unzip jq build-essential ncdu tmux make cmake clang pkg-config libssl-dev protobuf-compiler bc lz4 screen -y
sudo apt update
sudo apt install ufw -y
sudo ufw allow 22:65535/tcp
sudo ufw allow 22:65535/udp
sudo ufw deny out from any to 10.0.0.0/8
#sudo ufw deny out from any to 172.16.0.0/12
sudo ufw deny out from any to 192.168.0.0/16
sudo ufw deny out from any to 100.64.0.0/10
sudo ufw deny out from any to 198.18.0.0/15
sudo ufw deny out from any to 169.254.0.0/16
sudo ufw --force enable
sudo apt update
sudo apt install mc jq curl build-essential git wget git lz4 -y
sudo rm -rf /usr/local/go
curl https://dl.google.com/go/go1.22.4.linux-amd64.tar.gz | sudo tar -C /usr/local -zxvf -

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

source $HOME/.profile
sleep 1

echo "-----------------------------------------------------------------------------"
echo "install miner Hemi Network"

cd $HOME
wget https://github.com/hemilabs/heminetwork/releases/download/v0.7.0/heminetwork_v0.7.0_linux_amd64.tar.gz

tar -xvf heminetwork_v0.7.0_linux_amd64.tar.gz && rm heminetwork_v0.7.0_linux_amd64.tar.gz
mv heminetwork_v0.7.0_linux_amd64 heminetwork
rm -rf $HOME/heminetwork_v0.7.0_linux_amd64

echo "-----------------------------------------------------------------------------"
echo "Miner run"

if [ -z "$PRIVATE_KEY" ]; then
    echo "No priv key!!!"
    exit 1
fi

sudo tee /etc/systemd/system/hemi.service > /dev/null <<EOF
[Unit]
Description=Hemi miner
After=network.target

[Service]
User=$USER
Environment="POPM_BTC_PRIVKEY=$PRIVATE_KEY"
Environment="POPM_STATIC_FEE=4000"
Environment="POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public"
WorkingDirectory=$HOME/heminetwork
ExecStart=$HOME/heminetwork/popmd
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable hemi &>/dev/null
sudo systemctl daemon-reload
sudo systemctl start hemi

sleep 15

echo "-----------------------------------------------------------------------------"
echo "Hemi miner runs success"
echo "to check logs:"
echo "journalctl -n 100 -f -u hemi -o cat"
