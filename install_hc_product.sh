#!/usr/bin/env bash
# Installs a given Hashicorp product.

# Usage - provide product, version, operating system, architecture as arguments in that order.
# The version can be provided as 'latest' in which case the script will determine and install the latest version.
# The OS and Architecture arguments are optional and will default to 'linux' and 'amd64' respectively.

# Version 'latest' is not supported by some products. To confirm if a product is supported go to https://checkpoint-api.hashicorp.com

# check input arguments
if [ "$#" -lt 1 ]; then
    echo "usage: install_sh_product.sh <product> [<version> [<OS> [architecture]]]"
    exit 1
fi

# install needed packages
PKGS='wget unzip jq'
which wget ${PKGS} jq>>/dev/null || {
    sudo apt-get update >>/dev/null
    sudo apt-get install -y ${PKGS}>>/dev/null
}

# construct vars
PRODUCT="$1"

[ -z "$2" ] && VER="latest" || VER="$2"
[ "$VER" == "latest" ] && VER=$(curl -sSf https://checkpoint-api.hashicorp.com/v1/check/${PRODUCT} | jq -r '.current_version')

[ -z "$3" ] &&  OS='linux' || OS="$3"
[ -z "$4" ] && ARCH='amd64' || ARCH="$4"

FILE="${PRODUCT}_${VER}_${OS}_${ARCH}.zip"
URL="https://releases.hashicorp.com/$PRODUCT/$VER/$FILE"

# download product
wget -q -P /tmp $URL || {
    echo "==> Failed to download package form $URL"
    exit 1
}

# unzip
sudo unzip -o /tmp/$FILE -d /usr/local/bin

# cleanup
rm -f /tmp/$FILE
