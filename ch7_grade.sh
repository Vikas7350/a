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
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|perms-review|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start perms-review"
history -s "lab start perms-review"
lab start perms-review

# ============================================================
# Helper functions
# ============================================================

remote_sudo() {
    ssh student@serverb "echo student | sudo -S $1"
}

remote_as_user() {
    local USERNAME="$1"
    local COMMAND="$2"

    ssh student@serverb \
    "echo student | sudo -S -u $USERNAME bash -c '$COMMAND'"
}

# ============================================================
# Step 1: Connect to serverb and become root
# ============================================================

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

echo "[student@serverb ~]$ sudo -i"
history -s "sudo -i"

# ============================================================
# Step 2: Create /home/techdocs
# ============================================================

echo "[root@serverb ~]# mkdir /home/techdocs"
history -s "mkdir /home/techdocs"

remote_sudo "mkdir -p /home/techdocs"

# ============================================================
# Step 3: Change group ownership to techdocs
# ============================================================

echo "[root@serverb ~]# chown :techdocs /home/techdocs"
history -s "chown :techdocs /home/techdocs"

remote_sudo "chown :techdocs /home/techdocs"

# ============================================================
# Step 4: Verify initial permissions
# ============================================================

echo "[root@serverb ~]# ls -ld /home/techdocs"
history -s "ls -ld /home/techdocs"

remote_sudo "ls -ld /home/techdocs"

# ============================================================
# Step 5: Verify techdocs users cannot create files yet
# ============================================================

echo "[root@serverb ~]# sudo -u tech1 touch /home/techdocs/test_before.txt"
history -s "sudo -u tech1 touch /home/techdocs/test_before.txt"

remote_as_user "tech1" "touch /home/techdocs/test_before.txt 2>&1 || true"

# Remove test file if somehow created
remote_sudo "rm -f /home/techdocs/test_before.txt"

# ============================================================
# Step 6: Set setgid + 770
#
# 2 = setgid
# 7 = owner rwx
# 7 = group rwx
# 0 = others ---
#
# 2770
# ============================================================

echo "[root@serverb ~]# chmod 2770 /home/techdocs"
history -s "chmod 2770 /home/techdocs"

remote_sudo "chmod 2770 /home/techdocs"

# ============================================================
# Step 7: Verify permissions
# ============================================================

echo "[root@serverb ~]# ls -ld /home/techdocs"
history -s "ls -ld /home/techdocs"

remote_sudo "ls -ld /home/techdocs"

# ============================================================
# Step 8: Verify tech1 can create a file
# ============================================================

echo "[tech1@serverb ~]$ touch /home/techdocs/tech1.txt"
history -s "touch /home/techdocs/tech1.txt"

remote_as_user "tech1" "touch /home/techdocs/tech1.txt"

echo "[root@serverb ~]# ls -l /home/techdocs/tech1.txt"
history -s "ls -l /home/techdocs/tech1.txt"

remote_sudo "ls -l /home/techdocs/tech1.txt"

# ============================================================
# Step 9: Verify tech2 can create and edit files
# ============================================================

echo "[tech2@serverb ~]$ touch /home/techdocs/tech2.txt"
history -s "touch /home/techdocs/tech2.txt"

remote_as_user "tech2" "touch /home/techdocs/tech2.txt"

echo "[tech2@serverb ~]$ echo \"Tech documentation\" >> /home/techdocs/tech1.txt"
history -s 'echo "Tech documentation" >> /home/techdocs/tech1.txt'

remote_as_user "tech2" "echo 'Tech documentation' >> /home/techdocs/tech1.txt"

echo "[root@serverb ~]# ls -l /home/techdocs"
history -s "ls -l /home/techdocs"

remote_sudo "ls -l /home/techdocs"

# ============================================================
# Step 10: Verify database1 cannot create files
# ============================================================

echo "[database1@serverb ~]$ touch /home/techdocs/database1.txt"
history -s "touch /home/techdocs/database1.txt"

remote_as_user "database1" \
"touch /home/techdocs/database1.txt 2>&1 || true"

# ============================================================
# Step 11: Modify /etc/login.defs
#
# Normal users should use umask 007:
#
# Owner  -> rwx
# Group  -> rwx
# Others -> ---
# ============================================================

echo "[root@serverb ~]# sed -i 's/^[[:space:]]*UMASK[[:space:]].*/UMASK 007/' /etc/login.defs"
history -s "sed -i 's/^[[:space:]]*UMASK[[:space:]].*/UMASK 007/' /etc/login.defs"

remote_sudo "sed -i 's/^[[:space:]]*UMASK[[:space:]].*/UMASK 007/' /etc/login.defs"

# ============================================================
# Step 12: Verify login.defs
# ============================================================

echo "[root@serverb ~]# grep '^UMASK' /etc/login.defs"
history -s "grep '^UMASK' /etc/login.defs"

remote_sudo "grep '^UMASK' /etc/login.defs"

# ============================================================
# Step 13: Verify directory and group ownership
# ============================================================

echo "[root@serverb ~]# ls -ld /home/techdocs"
history -s "ls -ld /home/techdocs"

remote_sudo "ls -ld /home/techdocs"

# ============================================================
# Step 14: Verify group membership
# ============================================================

echo "[root@serverb ~]# id tech1"
history -s "id tech1"
remote_sudo "id tech1"

echo "[root@serverb ~]# id tech2"
history -s "id tech2"
remote_sudo "id tech2"

echo "[root@serverb ~]# id database1"
history -s "id database1"
remote_sudo "id database1"

# ============================================================
# Step 15: Clean temporary test files
# ============================================================

remote_sudo "rm -f /home/techdocs/database1.txt"

# ============================================================
# Return to WORKSTATION
# ============================================================

echo "[student@serverb ~]$ exit"
history -s "exit"
echo "logout"
echo "Connection to serverb closed."

# ============================================================
# IMPORTANT:
# Run grade/finish from the student's HOME directory
# ============================================================

cd "$HOME"

echo ""
echo "============================================================"
echo "Current directory:"
pwd
echo "============================================================"
echo ""

# ============================================================
# Grade Lab
# ============================================================

echo "[student@workstation ~]$ lab grade perms-review"
history -s "lab grade perms-review"

lab grade perms-review

# ============================================================
# Finish Lab
# ============================================================

echo ""
echo "[student@workstation ~]$ lab finish perms-review"
history -s "lab finish perms-review"

lab finish perms-review

history -w
