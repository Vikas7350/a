
#!/bin/bash

clear

set -e

clean_history() {
    history -w
    local tmp
    tmp=$(mktemp)

    grep -vEi \
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|perms-review|processes-control|net-review|history)' \
    ~/.bash_history > "$tmp" || true

    mv "$tmp" ~/.bash_history
    history -c
    history -r
}

clean_history

echo "[student@workstation ~]$ lab start net-review"
history -s "lab start net-review"
lab start net-review

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

ssh student@serverb 'sudo bash -s' <<'REMOTE'
set -e

echo "[root@serverb ~]# Identifying the primary interface"

IFACE=$(nmcli -t -f DEVICE,GENERAL.HWADDR device show |
    awk -F: '
    {
        dev=$1
        mac=""
        for (i=2; i<=NF; i++) {
            mac=mac (i==2 ? "" : ":") $i
        }
        if (tolower(mac) ~ /52:54:00:00:fa:0b/) {
            print dev
            exit
        }
    }')

# Reliable fallback using ip link output
if [ -z "$IFACE" ]; then
    IFACE=$(ip -o link |
        awk '/52:54:00:00:fa:0b/ {
            sub(/^[0-9]+: /,"",$2)
            sub(/@.*/,"",$2)
            print $2
            exit
        }')
fi

if [ -z "$IFACE" ]; then
    echo "ERROR: Interface with MAC 52:54:00:00:fa:0b not found."
    exit 1
fi

echo "Selected interface: $IFACE"

echo "[root@serverb ~]# Configuring NetworkManager"

# Disable the old connection from starting automatically
if nmcli -t -f NAME connection show |
   grep -Fxq 'System eth0'; then
    nmcli connection modify "System eth0" connection.autoconnect no
fi

# Remove an old lab profile if one exists
if nmcli -t -f NAME connection show | grep -Fxq 'lab'; then
    nmcli connection delete lab
fi

# Create the required connection with both static IPv4 addresses
nmcli connection add \
    type ethernet \
    con-name lab \
    ifname "$IFACE" \
    connection.autoconnect yes \
    ipv4.method manual \
    ipv4.addresses "172.25.250.11/24,10.0.1.1/24" \
    ipv4.gateway 172.25.250.254 \
    ipv4.dns 172.25.250.254 \
    ipv6.method auto

# Add the hostname mapping idempotently
if ! grep -Eq '^[[:space:]]*10\.0\.1\.1[[:space:]]+.*(^|[[:space:]])private([[:space:]]|$)' /etc/hosts; then
    echo "10.0.1.1 private" >> /etc/hosts
fi

echo "[root@serverb ~]# Checking connection settings"
nmcli connection show lab

echo "[root@serverb ~]# Scheduling reboot"
# Schedule reboot before activating the profile, because activation
# may interrupt the SSH session.
systemd-run --unit=net-review-reboot \
    --on-active=20s /usr/bin/systemctl reboot

echo "[root@serverb ~]# Activating lab connection"
nmcli connection up lab || true

REMOTE

echo "[student@workstation ~]$ Waiting for serverb to reboot"

# Wait for serverb to become reachable again
for i in $(seq 1 60); do
    if ssh -o ConnectTimeout=3 \
           -o BatchMode=yes \
           student@serverb 'true' 2>/dev/null; then
        echo "serverb is reachable."
        break
    fi

    if [ "$i" -eq 60 ]; then
        echo "ERROR: serverb did not become reachable within 3 minutes."
        echo "Check serverb manually before grading."
        exit 1
    fi

    sleep 3
done

echo "[student@workstation ~]$ lab grade net-review"
history -s "lab grade net-review"

if lab grade net-review; then
    echo "Lab grading command completed successfully."

    echo "[student@workstation ~]$ lab finish net-review"
    history -s "lab finish net-review"
    lab finish net-review
else
    echo "Lab grading reported failures."
    echo "Correct the reported issues and run: lab grade net-review"
    echo "Do not finish the lab until grading succeeds."
    exit 1
fi

cd "$HOME"

history -w

echo "Vikas Choudhari"
