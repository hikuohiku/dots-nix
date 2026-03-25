#!/usr/bin/env bash

# Set PATH to include Nix packages
PATH="/run/current-system/sw/bin:$PATH"

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

VPN_INTERFACE=ppp0
VPN_TARGET_HOST=133.10.204.26
PROXY_INTERFACE="Wi-Fi"
VPN_SERVICE="org.nixos.openfortivpn"
SSH_SERVICE="org.nixos.ssh-socks"

# --- Status Checks ---

check_vpn() {
    if ifconfig | grep -A1 "$VPN_INTERFACE" | grep -q inet; then
        return 0
    else
        return 1
    fi
}

check_proxy() {
    if networksetup -getautoproxyurl "$PROXY_INTERFACE" | grep -q "Enabled: Yes"; then
        return 0
    else
        return 1
    fi
}

check_ssh() {
    # Check if the service is running (pid is present)
    if launchctl list | grep -q "$SSH_SERVICE"; then
         # Also check if it has a PID (second column is not -)
         if launchctl list | grep "$SSH_SERVICE" | awk '{print $1}' | grep -q -v "-"; then
             return 0
         fi
    fi
    return 1
}

# --- Actions ---

add_route() {
    sudo _add-vpn-route
}

connect_vpn() {
    sudo launchctl start "$VPN_SERVICE"
    until check_vpn; do sleep 1; done
}

setup_connection() {
    connect_vpn
    add_route
}

disconnect_vpn() {
    sudo launchctl stop "$VPN_SERVICE"
    until ! check_vpn; do sleep 1; done
}

enable_proxy() {
    networksetup -setautoproxyurl "$PROXY_INTERFACE" "file:///Users/hikuo/proxy.pac"
}

disable_proxy() {
    networksetup -setautoproxystate "$PROXY_INTERFACE" off
}

start_ssh() {
    launchctl start "$SSH_SERVICE"
}

stop_ssh() {
    launchctl stop "$SSH_SERVICE"
}

# --- Argument Handling ---

case "$1" in
    connect_all)
        setup_connection
        enable_proxy
        start_ssh
        ;;
    disconnect_all)
        disconnect_vpn
        disable_proxy
        stop_ssh
        ;;
    toggle_vpn)
        if check_vpn; then disconnect_vpn; else setup_connection; fi
        ;;
    toggle_proxy)
        if check_proxy; then disable_proxy; else enable_proxy; fi
        ;;
    toggle_ssh)
        if check_ssh; then stop_ssh; else start_ssh; fi
        ;;
esac

# --- Output Generation ---

# Count connected services
CONNECTED_COUNT=0
check_vpn && ((CONNECTED_COUNT++))
check_proxy && ((CONNECTED_COUNT++))
check_ssh && ((CONNECTED_COUNT++))

# Header - Display overall status with single icon
if [ "$CONNECTED_COUNT" -eq 3 ]; then
    # All connected
    echo "✓"
elif [ "$CONNECTED_COUNT" -eq 0 ]; then
    # All disconnected
    echo "✗"
else
    # Partial connection
    echo "⚠"
fi
echo "---"

# Main Actions
if check_vpn && check_proxy && check_ssh; then
    echo "Disconnect All | shell='$0' param1=disconnect_all terminal=false refresh=true"
else
    echo "Connect All | shell='$0' param1=connect_all terminal=false refresh=true"
fi

echo "---"

# Individual Controls
if check_vpn; then
    echo "VPN: Connected | color=green shell='$0' param1=toggle_vpn terminal=false refresh=true"
else
    echo "VPN: Disconnected | color=red shell='$0' param1=toggle_vpn terminal=false refresh=true"
fi

if check_proxy; then
    echo "Proxy: Enabled | color=green shell='$0' param1=toggle_proxy terminal=false refresh=true"
else
    echo "Proxy: Disabled | color=red shell='$0' param1=toggle_proxy terminal=false refresh=true"
fi

if check_ssh; then
    echo "SSH: Running | color=green shell='$0' param1=toggle_ssh terminal=false refresh=true"
else
    echo "SSH: Stopped | color=red shell='$0' param1=toggle_ssh terminal=false refresh=true"
fi
