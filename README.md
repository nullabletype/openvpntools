# openvpntools

`auto-connect.sh` is a script file which you can use to monitor your `OpenVPN` connection for disconnects, update both `UFW` and your `OpenVPN` file and reconnect for you. This is really handy for VPN providers that rotate IP addresses frequently and you wish to restrict traffic when your server isn't connected to the VPN of your choosing. Works with `private internet access`, `NordVPN`, `ProtonVPN` etc.

## Requirements
[`dig`](https://man.openbsd.org/dig.1) - For updating the IP address list

[`UFW`](https://wiki.ubuntu.com/UncomplicatedFirewall) - For your killswitch

[`OpenVPN`](https://openvpn.net/) - To connect to your VPN

## Usage

### Setup
This script uses two template files, `openvpn.ovpn.template` and `user.rules.template`. In both files, place `[content]` where the domain or IP addresses would normally be. In the `OpenVPN` connection file this is the line beginning `remote ` and for the `UFW` `user.rules` file, next to any other IP configuration. Templates are provided as examples.

The script currently expects your `user.rules` file to live in `/etc/ufw/user.rules`, you may need to adjust this.

### How to run
Usage is pretty simple, just call with a domain to refresh IP addresses from and your device name to monitor (normally `ton0`).

    ./auto-connect.sh "my.vpn.domain" "tun0"

Works well with `cron`

    */1 * * * * cd /home/account/openvpn && ./ac.sh "my.vpn.domain" "tun0"  > out.out

## Disclaimer
I'm no UNIX expert; this script may contains bugs and no doubt can be improved. If you have any suggestions, i'm very open to merge requests ❤