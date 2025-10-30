#!/usr/bin/env bash

# Get current status of a OpenFortiVPN connection with options to connect/disconnect.
# Commands that require admin permissions should be whitelisted with 'visudo', e.g.:
# YOURUSERNAME ALL=(ALL) NOPASSWD: /usr/local/bin/openfortivpn
# YOURUSERNAME ALL=(ALL) NOPASSWD: /usr/bin/killall -2 openfortivpn
# To use openfortivpn in an easy way you can create file like: /Documents/.fortivpn-config and put your crential in it as following:
#
# host=123.45.678.9
# port=1234
# username=FOO
# password=MYPASSWORDCHARACHTERS
# trusted-cert=MYCERTIFICATECHARACHTERS

VPN_EXECUTABLE=@openfortivpn@
VPN_EXECUTABLE_PARAMS="-c$HOME/Documents/.fortivpn-config" # Optional
VPN_INTERFACE=ppp0
# Command to determine if OpenFortiVPN is connected or disconnected
VPN_CONNECTED="ifconfig | egrep -A1 $VPN_INTERFACE | grep inet"
# Command to run to disconnect OpenFortiVPN
VPN_DISCONNECT_CMD="sudo killall -2 openfortivpn"

case "$1" in
    connect)
        # VPN connection command, should eventually result in $VPN_CONNECTED,
        sudo "$VPN_EXECUTABLE" "$VPN_EXECUTABLE_PARAMS" &> /dev/null &
        # Wait for connection so menu item refreshes instantly
        until eval "$VPN_CONNECTED"; do sleep 1; done

        # Set auto proxy URL
        networksetup -setautoproxyurl "Wi-Fi" "file:///Users/hikuo/proxy.pac"

        # Start autossh-socks service
        launchctl start org.nixos.autossh-socks
        ;;
    disconnect)
            eval "$VPN_DISCONNECT_CMD"
        # Wait for disconnection so menu item refreshes instantly
        until [ -z "$(eval "$VPN_CONNECTED")" ]; do sleep 1; done

        # Disable auto proxy
        networksetup -setautoproxystate "Wi-Fi" off

        # Stop autossh-socks service
        launchctl stop org.nixos.autossh-socks
        ;;
esac

if [ -n "$(eval "$VPN_CONNECTED")" ]; then
    echo "✔"
    echo '---'
    echo "Disconnect OpenFortiVPN | bash='$0' param1=disconnect terminal=false refresh=true"
    exit
else
    echo "✘"
    echo '---'
    echo "Connect OpenFortiVPN | bash='$0' param1=connect terminal=false refresh=true"
    exit
fi
