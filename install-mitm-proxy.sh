#!/user/bin/env bash
# Installs and starts Mitm proxy.

set -exo pipefail

which mitmproxy && {
    echo "mitmproxy is already installed"
    exit 0
}

sudo apt-get update
sudo apt-get install -y python3-pip

# Installatoin of mitmproxy on bionic seem to require installing the python dependencies explicitly.
sudo python3 -m pip install mitmproxy
# sudo apt-get install -y mitmproxy

# start the mitmproxy so it generates the SSL certificates
export LANG=en_US.UTF-8
[ -d $HOME/.mitmproxy/ ] || mkdir $HOME/.mitmproxy/
mitmweb --web-host '*' 2>&1>$HOME/.mitmproxy/log.txt &
sleep 5

# add mitmproxy CA certificate to the trusted root CAs
sudo cp $HOME/.mitmproxy/mitmproxy-ca-cert.cer /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt
sudo update-ca-certificates

# add proxy enironment variables to the current user's bash profile
# echo 'export HTTP_PROXY=127.0.0.1:8080' | tee -a $HOME/.profile
# echo 'export HTTPS_PROXY=127.0.0.1:8080' | tee -a $HOME/.profile