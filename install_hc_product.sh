#!/usr/bin/env bash
# Installs a given Hashicorp product

# Usage - provide product, version, operating system, architecture as arguments in that order.

# check input arguments
if [ "$#" != 4 ]; then
    echo "usage: install_sh_product.sh <product> <version> <OS> <architecture>"
    exit 1
fi

# construct vars
PRODUCT="$1"
VER="$2"
OS="$3"
ARCH="$4"
FILE="${PRODUCT}_${VER}_${OS}_${ARCH}.zip"
URL="https://releases.hashicorp.com/$PRODUCT/$VER/$FILE"

# install needed packages
which wget unzip >>/dev/null || {
    sudo apt-get update >>/dev/null
    sudo apt-get install -y wget unzip >>/dev/null
}

# download product
wget -q -P /tmp $URL || {
    echo "failed to download package form $URL"
    exit 1
}

# unzip
sudo unzip -o /tmp/$FILE -d /usr/local/bin

# cleanup
rm -f /tmp/$FILE
