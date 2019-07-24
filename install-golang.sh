#!/usr/bin/env bash
# Installs Golang

# Arguments:
# 1 (Required) - golang version to install X.X.X
# 2 (Required) - OS e.g linux, darwin, widnows
# 3 (Required) - Architecture e.g. 386, amd64

if [ $# != 3 ]; then
    echo "usage $0 <golang_version> <OS> <ARCH>"
    exit 1
fi

export GOLANG_FILE="go${1}.${2}-${3}.tar.gz"

# install Golang
wget -q -P /tmp https://dl.google.com/go/${GOLANG_FILE} || {
    echo "error downloading Golang package"
    exit 1
}
sudo tar -C /usr/local -xzf /tmp/${GOLANG_FILE} || {
    echo "error extracting Golang package"
    exit 1
}

cat /etc/profile.d/golang_config.sh 2>/dev/null | grep 'export PATH=' || {
    echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/golang_config.sh
}

# clean up
rm /tmp/${GOLANG_FILE}
