#!/bin/bash

clear

# ============================================================
# Clean history
# ============================================================

clean_history() {
    history -w

    local tmp
    tmp=$(mktemp)

    grep -vEi \
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|services-review|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start services-review"
history -s "lab start services-review"
lab start services-review

# ============================================================
# Helper function
# Execute a command on serverb as student using sudo
# ============================================================

remote_sudo() {
    ssh student@serverb "echo student | sudo -S $1"
}

# ============================================================
# Step 1: Connect to serverb
# ============================================================

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

# ============================================================
# Step 2: Start psacct service
# ============================================================

echo "[student@serverb ~]$ sudo systemctl start psacct"
history -s "sudo systemctl start psacct"
remote_sudo "systemctl start psacct"

# ============================================================
# Step 3: Enable psacct service at boot
# ============================================================

echo "[student@serverb ~]$ sudo systemctl enable psacct"
history -s "sudo systemctl enable psacct"
remote_sudo "systemctl enable psacct"

# ============================================================
# Step 4: Stop rsyslog service
# ============================================================

echo "[student@serverb ~]$ sudo systemctl stop rsyslog"
history -s "sudo systemctl stop rsyslog"
remote_sudo "systemctl stop rsyslog"

# ============================================================
# Step 5: Disable rsyslog service at boot
# ============================================================

echo "[student@serverb ~]$ sudo systemctl disable rsyslog"
history -s "sudo systemctl disable rsyslog"
remote_sudo "systemctl disable rsyslog"

# ============================================================
# Step 6: Verify before reboot
# ============================================================

echo ""
echo "============================================================"
echo "Verification before reboot"
echo "============================================================"

remote_sudo "systemctl is-active psacct"
remote_sudo "systemctl is-enabled psacct"

remote_sudo "systemctl is-active rsyslog"
remote_sudo "systemctl is-enabled rsyslog"

# ============================================================
# Step 7: Reboot serverb
# ============================================================

echo ""
echo "[student@serverb ~]$ sudo reboot"
history -s "sudo reboot"

ssh student@serverb "echo student | sudo -S reboot"

# Wait for serverb to reboot
sleep 15

# ============================================================
# Step 8: Verify services after reboot
# ============================================================

echo ""
echo "============================================================"
echo "Verification after reboot"
echo "============================================================"

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

remote_sudo "systemctl is-active psacct"
remote_sudo "systemctl is-enabled psacct"

remote_sudo "systemctl is-active rsyslog"
remote_sudo "systemctl is-enabled rsyslog"

# ============================================================
# Step 9: Grade Lab
# ============================================================

echo ""
echo "[student@workstation ~]$ lab grade services-review"
history -s "lab grade services-review"

lab grade services-review

# ============================================================
# Step 10: Finish Lab
# ============================================================

echo ""
echo "[student@workstation ~]$ cd ~"
cd ~

echo "[student@workstation ~]$ lab finish services-review"
history -s "lab finish services-review"

lab finish services-review

# ============================================================
# Save cleaned history
# ============================================================

history -w
