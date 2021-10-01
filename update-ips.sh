#!/bin/bash

full_path=$(realpath $0)
dir_path=$(dirname $full_path)
echo "Executing in $dir_path"

if [ -z "$1" ]; then
    echo "Please specify a domain name"
    exit 1
fi

domain=$1

if [ -z "$2" ]; then
    echo "Please specify a device name"
    exit 1
fi

device=$2

echo "Using domain $domain and device $device"

function updateIps() {

    if [ -z "$1" ]; then
        echo "Please specify a domain name"
        exit 1
    fi

    ipoutput=$(dig $1 +short)

    if [ -z "$ipoutput" ]; then
        echo "No ips found for $1"
        exit 1
    fi

    echo "Found ips $ipoutput"

    readarray -t ips <<<"$ipoutput"

    updateOpenVpn $ips
    updateUfw $ips
}

function updateOpenVpn() {
    ips=$1
    openvpnoutput=''

    for i in "${ips[@]}"
    do
    :
    openvpnoutput+=$"remote $i 1198\n"
    done

    if test -f "$dir_path/openvpn.ovpn.tmp"; then
        echo "Deleting tmp file..."
        rm "$dir_path/openvpn.ovpn.tmp"
    fi

    cp "$dir_path/openvpn.ovpn.template" "$dir_path/openvpn.ovpn.tmp"

    sed -i -e "s/\[content\]/${openvpnoutput}/g" "$dir_path/openvpn.ovpn.tmp" "$dir_path/openvpn.ovpn.tmp"

    mv "$dir_path/openvpn.ovpn.tmp" "openvpn.ovpn"
}

function updateUfw() {

    ips=$1

    ufwoutput=''

    for i in "${ips[@]}"
    do
    :
    ufwoutput+=$"### tuple ### allow udp any $i any 0.0.0.0\/0 out\n"
    ufwoutput+=$"-A ufw-user-output -p udp -d $i -j ACCEPT\n\n"
    done

    if test -f "$dir_path/user.rules.tmp"; then
        echo "Deleting tmp file..."
        rm "$dir_path/user.rules.tmp"
    fi

    cp "$dir_path/user.rules.template" "$dir_path/user.rules.tmp"

    sed -i -e "s/\[content\]/${ufwoutput}/g" "$dir_path/user.rules.tmp" "$dir_path/user.rules.tmp"

    mv "$dir_path/user.rules.tmp" /etc/ufw/user.rules

    echo "Reloading ufw"
    ufw reload
}

function getStatus () {
        echo "Attempting to get device status..."
        ip address show | grep $1 && return 1
        return 0
}

echo "Checking device status..."

getStatus $device
if [[ $? == 0 ]]; then
        echo "openvpn is not connected!"
        echo "Reconnecting!"

        #Update config
        updateIps $domain &> $dir_path/renew.out &disown

        openvpn --config "$dir_path/openvpn.ovpn" &>$dir_path/out.out &disown
else
        echo "openvpn is connected!"
fi