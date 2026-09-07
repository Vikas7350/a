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
# Lab Instructions Execution
# ============================================================

# Step 1: Connect to servera as student
echo "[student@workstation ~]$ ssh student@servera"
history -s "ssh student@servera"

# Step 2: Switch to operator1
echo "[student@servera ~]$ su - operator1"
history -s "su - operator1"

# ============================================================
# Step 3: Check default umask
# ============================================================

echo "[operator1@servera ~]$ umask"
history -s "umask"
ssh student@servera "echo redhat | su - operator1 -c 'umask'"

# ============================================================
# Step 4: Create /tmp/shared and test default permissions
# ============================================================

echo "[operator1@servera ~]$ mkdir /tmp/shared"
history -s "mkdir /tmp/shared"
ssh student@servera "echo student | sudo -S mkdir -p /tmp/shared"

echo "[operator1@servera ~]$ ls -ld /tmp/shared"
history -s "ls -ld /tmp/shared"
ssh student@servera "ls -ld /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/defaults"
history -s "touch /tmp/shared/defaults"
ssh student@servera "sudo -u operator1 touch /tmp/shared/defaults"

echo "[operator1@servera ~]$ ls -l /tmp/shared/defaults"
history -s "ls -l /tmp/shared/defaults"
ssh student@servera "ls -l /tmp/shared/defaults"

# ============================================================
# Step 5: Change group ownership to operators
# ============================================================

echo "[operator1@servera ~]$ chown :operators /tmp/shared"
history -s "chown :operators /tmp/shared"
ssh student@servera "echo student | sudo -S chown :operators /tmp/shared"

echo "[operator1@servera ~]$ ls -ld /tmp/shared"
history -s "ls -ld /tmp/shared"
ssh student@servera "ls -ld /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/group"
history -s "touch /tmp/shared/group"
ssh student@servera "sudo -u operator1 touch /tmp/shared/group"

echo "[operator1@servera ~]$ ls -l /tmp/shared/group"
history -s "ls -l /tmp/shared/group"
ssh student@servera "ls -l /tmp/shared/group"

# ============================================================
# Step 6: Set setgid permission
# ============================================================

echo "[operator1@servera ~]$ chmod g+s /tmp/shared"
history -s "chmod g+s /tmp/shared"
ssh student@servera "echo student | sudo -S chmod g+s /tmp/shared"

echo "[operator1@servera ~]$ touch /tmp/shared/ops_db.txt"
history -s "touch /tmp/shared/ops_db.txt"
ssh student@servera "sudo -u operator1 touch /tmp/shared/ops_db.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_db.txt"
history -s "ls -l /tmp/shared/ops_db.txt"
ssh student@servera "ls -l /tmp/shared/ops_db.txt"

# ============================================================
# Step 7: Test umask 027
# ============================================================

echo "[operator1@servera ~]$ touch /tmp/shared/ops_net.txt"
history -s "touch /tmp/shared/ops_net.txt"
ssh student@servera "sudo -u operator1 touch /tmp/shared/ops_net.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_net.txt"
history -s "ls -l /tmp/shared/ops_net.txt"
ssh student@servera "ls -l /tmp/shared/ops_net.txt"

echo "[operator1@servera ~]$ umask 027"
history -s "umask 027"
ssh student@servera "echo student | sudo -S bash -c 'su - operator1 -c \"umask 027\"'"

echo "[operator1@servera ~]$ umask"
history -s "umask"
ssh student@servera "echo student | sudo -S bash -c 'su - operator1 -c \"umask\"'"

echo "[operator1@servera ~]$ touch /tmp/shared/ops_prod.txt"
history -s "touch /tmp/shared/ops_prod.txt"
ssh student@servera "echo student | sudo -S bash -c 'su - operator1 -c \"umask 027; touch /tmp/shared/ops_prod.txt\"'"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_prod.txt"
history -s "ls -l /tmp/shared/ops_prod.txt"
ssh student@servera "ls -l /tmp/shared/ops_prod.txt"

# ============================================================
# Step 8: New terminal / login as operator1
# ============================================================

echo "[student@workstation ~]$ ssh operator1@servera"
history -s "ssh operator1@servera"

# ============================================================
# Step 9: Check umask in new login session
# ============================================================

echo "[operator1@servera ~]$ umask"
history -s "umask"
ssh operator1@servera "umask"

# ============================================================
# Step 10: Make umask 007 permanent
# ============================================================

echo "[operator1@servera ~]$ echo \"umask 007\" >> ~/.bashrc"
history -s 'echo "umask 007" >> ~/.bashrc'
ssh student@servera "echo student | sudo -S bash -c 'echo \"umask 007\" >> /home/operator1/.bashrc; chown operator1:operator1 /home/operator1/.bashrc'"

echo "[operator1@servera ~]$ cat ~/.bashrc"
history -s "cat ~/.bashrc"
ssh operator1@servera "tail -n 5 ~/.bashrc"

# ============================================================
# Step 11: Log in again and verify permanent umask
# ============================================================

echo "[operator1@servera ~]$ exit"
history -s "exit"
echo "logout"

echo "[student@workstation ~]$ ssh operator1@servera"
history -s "ssh operator1@servera"

echo "[operator1@servera ~]$ umask"
history -s "umask"
ssh operator1@servera "umask"

# ============================================================
# Step 12: Create ops_prod2.txt with umask 007
# ============================================================

echo "[operator1@servera ~]$ touch /tmp/shared/ops_prod2.txt"
history -s "touch /tmp/shared/ops_prod2.txt"
ssh operator1@servera "touch /tmp/shared/ops_prod2.txt"

echo "[operator1@servera ~]$ ls -l /tmp/shared/ops_prod2.txt"
history -s "ls -l /tmp/shared/ops_prod2.txt"
ssh operator1@servera "ls -l /tmp/shared/ops_prod2.txt"

# ============================================================
# Exit all operator1/student shells
# ============================================================

echo "[operator1@servera ~]$ exit"
history -s "exit"
echo "logout"

echo "[student@workstation ~]$ exit"
history -s "exit"
echo "logout"

# ============================================================
# Finish Lab
# ============================================================

echo "[student@workstation ~]$ lab finish perms-default"
history -s "lab finish perms-default"
lab finish perms-default

history -w
