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
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start perms-default"
history -s "lab start perms-default"
lab start perms-default

# ============================================================
# Helper function
# Execute a command on servera as student using sudo
# ============================================================

remote_sudo() {
    ssh student@servera "echo student | sudo -S $1"
}

remote_operator() {
    ssh student@servera "echo student | sudo -S -u operator1 bash -c '$1'"
}

# ============================================================
# Step 1: Connect to servera
# ============================================================

echo "[student@workstation ~]$ ssh student@servera"
history -s "ssh student@servera"

# ============================================================
# Step 2: Switch to operator1
# ============================================================

echo "[student@servera ~]$ su - operator1"
history -s "su - operator1"

# ============================================================
# Step 3: Check default umask
# ============================================================

echo "[operator1@servera ~]$ umask"
history -s "umask"
remote_operator "umask"

# ============================================================
# Step 4: Create /tmp/shared AS operator1
# ============================================================

echo "[operator1@servera ~]$ mkdir /tmp/shared"
history -s "mkdir /tmp/shared"
remote_operator "mkdir /tmp/shared"

echo "[operator1@servera ~]$ ls -ld /tmp/shared"
history -s "ls -ld /tmp/shared"
remote_sudo "ls -ld /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/defaults"
history -s "touch /tmp/shared/defaults"
remote_operator "touch /tmp/shared/defaults"

echo "[operator1@servera ~]$ ls -l /tmp/shared/defaults"
history -s "ls -l /tmp/shared/defaults"
remote_sudo "ls -l /tmp/shared/defaults"

# ============================================================
# Step 5: Change group ownership to operators
# ============================================================

echo "[operator1@servera ~]$ chown :operators /tmp/shared"
history -s "chown :operators /tmp/shared"
remote_operator "chown :operators /tmp/shared"

echo "[operator1@servera ~]$ ls -ld /tmp/shared"
history -s "ls -ld /tmp/shared"
remote_sudo "ls -ld /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/group"
history -s "touch /tmp/shared/group"
remote_operator "touch /tmp/shared/group"

echo "[operator1@servera ~]$ ls -l /tmp/shared/group"
history -s "ls -l /tmp/shared/group"
remote_sudo "ls -l /tmp/shared/group"

# ============================================================
# Step 6: Set setgid permission
# ============================================================

echo "[operator1@servera ~]$ chmod g+s /tmp/shared"
history -s "chmod g+s /tmp/shared"
remote_operator "chmod g+s /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/ops_db.txt"
history -s "touch /tmp/shared/ops_db.txt"
remote_operator "touch /tmp/shared/ops_db.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_db.txt"
history -s "ls -l /tmp/shared/ops_db.txt"
remote_sudo "ls -l /tmp/shared/ops_db.txt"

# ============================================================
# Step 7: Create ops_net.txt with umask 022
# ============================================================

echo "[operator1@servera ~]$ touch /tmp/shared/ops_net.txt"
history -s "touch /tmp/shared/ops_net.txt"
remote_operator "touch /tmp/shared/ops_net.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_net.txt"
history -s "ls -l /tmp/shared/ops_net.txt"
remote_sudo "ls -l /tmp/shared/ops_net.txt"

# ============================================================
# Step 8: Change umask to 027
# ============================================================

echo "[operator1@servera ~]$ umask 027"
history -s "umask 027"

remote_operator "umask 027; umask"

echo "[operator1@servera ~]$ umask"
history -s "umask"
remote_operator "umask 027; umask"

# ============================================================
# Step 9: Create ops_prod.txt with umask 027
# ============================================================

echo "[operator1@servera ~]$ touch /tmp/shared/ops_prod.txt"
history -s "touch /tmp/shared/ops_prod.txt"
remote_operator "umask 027; touch /tmp/shared/ops_prod.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_prod.txt"
history -s "ls -l /tmp/shared/ops_prod.txt"
remote_sudo "ls -l /tmp/shared/ops_prod.txt"

# ============================================================
# Step 10: Make umask 007 permanent
# ============================================================

echo "[operator1@servera ~]$ echo \"umask 007\" >> ~/.bashrc"
history -s 'echo "umask 007" >> ~/.bashrc'

remote_sudo "bash -c 'echo \"umask 007\" >> /home/operator1/.bashrc'"

# Make sure operator1 owns .bashrc
remote_sudo "chown operator1:operator1 /home/operator1/.bashrc"

echo "[operator1@servera ~]$ tail ~/.bashrc"
history -s "tail ~/.bashrc"
remote_sudo "tail -n 5 /home/operator1/.bashrc"

# ============================================================
# Step 11: Verify permanent umask in a fresh login shell
# ============================================================

echo "[student@workstation ~]$ ssh operator1@servera"
history -s "ssh operator1@servera"

echo "[operator1@servera ~]$ umask"
history -s "umask"

# Use a fresh login shell so .bashrc is loaded
remote_sudo "su - operator1 -c 'umask'"

# ============================================================
# Step 12: Create ops_prod2.txt with umask 007
# ============================================================

echo "[operator1@servera ~]$ touch /tmp/shared/ops_prod2.txt"
history -s "touch /tmp/shared/ops_prod2.txt"

remote_operator "umask 007; touch /tmp/shared/ops_prod2.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_prod2.txt"
history -s "ls -l /tmp/shared/ops_prod2.txt"
remote_sudo "ls -l /tmp/shared/ops_prod2.txt"

# ============================================================
# Verify final permissions and ownership
# ============================================================

echo ""
echo "============================================================"
echo "Final verification"
echo "============================================================"

remote_sudo "ls -ld /tmp/shared"
remote_sudo "ls -l /tmp/shared"

# ============================================================
# Finish Lab
# ============================================================

echo ""
echo "[student@workstation ~]$ lab finish perms-default"
history -s "lab finish perms-default"

lab finish perms-default

history -w
