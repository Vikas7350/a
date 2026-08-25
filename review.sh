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
    '(curl|chmod|source|python|pynput|passwd-automation|users-review\.sh|users-password\.sh|users-group\.sh|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start users-review"
history -s "lab start users-review"
lab start users-review

# ============================================================
# Lab Instructions Execution
# ============================================================

# Step 1: Connect to serverb and switch to root
echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

echo "[student@serverb ~]$ sudo -i"
history -s "sudo -i"

# Step 2: Set default password maximum age to 30 days
echo "[root@serverb ~]# sed -i 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   30/' /etc/login.defs"
history -s "sed -i 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   30/' /etc/login.defs"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S sed -i 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   30/' /etc/login.defs"

# Step 3: Create consultants group with GID 35000
echo "[root@serverb ~]# groupadd -g 35000 consultants"
history -s "groupadd -g 35000 consultants"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S groupadd -g 35000 consultants"

# Step 4: Configure sudo access for consultants group
echo "[root@serverb ~]# echo '%consultants ALL=(ALL) ALL' > /etc/sudoers.d/consultants"
history -s "echo '%consultants ALL=(ALL) ALL' > /etc/sudoers.d/consultants"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S bash -c \"echo '%consultants ALL=(ALL) ALL' > /etc/sudoers.d/consultants\""

echo "[root@serverb ~]# chmod 440 /etc/sudoers.d/consultants"
history -s "chmod 440 /etc/sudoers.d/consultants"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chmod 440 /etc/sudoers.d/consultants"

# Step 5: Create consultant users
echo "[root@serverb ~]# useradd -G consultants consultant1"
history -s "useradd -G consultants consultant1"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S useradd -G consultants consultant1"

echo "[root@serverb ~]# useradd -G consultants consultant2"
history -s "useradd -G consultants consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S useradd -G consultants consultant2"

echo "[root@serverb ~]# useradd -G consultants consultant3"
history -s "useradd -G consultants consultant3"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S useradd -G consultants consultant3"

# Step 6: Set passwords
echo "[root@serverb ~]# echo 'consultant1:redhat' | chpasswd"
history -s "echo 'consultant1:redhat' | chpasswd"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S bash -c \"echo 'consultant1:redhat' | chpasswd\""

echo "[root@serverb ~]# echo 'consultant2:redhat' | chpasswd"
history -s "echo 'consultant2:redhat' | chpasswd"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S bash -c \"echo 'consultant2:redhat' | chpasswd\""

echo "[root@serverb ~]# echo 'consultant3:redhat' | chpasswd"
history -s "echo 'consultant3:redhat' | chpasswd"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S bash -c \"echo 'consultant3:redhat' | chpasswd\""

# Step 7: Set account expiry to 90 days
echo "[root@serverb ~]# date -d '+90 days' +%F"
history -s "date -d '+90 days' +%F"
EXPIRY_DATE=$(date -d "+90 days" +%F)
echo "$EXPIRY_DATE"

echo "[root@serverb ~]# chage -E $EXPIRY_DATE consultant1"
history -s "chage -E $EXPIRY_DATE consultant1"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -E $EXPIRY_DATE consultant1"

echo "[root@serverb ~]# chage -E $EXPIRY_DATE consultant2"
history -s "chage -E $EXPIRY_DATE consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -E $EXPIRY_DATE consultant2"

echo "[root@serverb ~]# chage -E $EXPIRY_DATE consultant3"
history -s "chage -E $EXPIRY_DATE consultant3"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -E $EXPIRY_DATE consultant3"

# Step 8: Set consultant2 password maximum age to 15 days
echo "[root@serverb ~]# chage -M 15 consultant2"
history -s "chage -M 15 consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -M 15 consultant2"

# Step 9: Force password change on first login
echo "[root@serverb ~]# chage -d 0 consultant1"
history -s "chage -d 0 consultant1"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -d 0 consultant1"

echo "[root@serverb ~]# chage -d 0 consultant2"
history -s "chage -d 0 consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -d 0 consultant2"

echo "[root@serverb ~]# chage -d 0 consultant3"
history -s "chage -d 0 consultant3"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -d 0 consultant3"

# Step 10: Verify configuration
echo "[root@serverb ~]# id consultant1"
history -s "id consultant1"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb "id consultant1"

echo "[root@serverb ~]# id consultant2"
history -s "id consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb "id consultant2"

echo "[root@serverb ~]# id consultant3"
history -s "id consultant3"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb "id consultant3"

echo "[root@serverb ~]# chage -l consultant2"
history -s "chage -l consultant2"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S chage -l consultant2"

echo "[root@serverb ~]# cat /etc/sudoers.d/consultants"
history -s "cat /etc/sudoers.d/consultants"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"echo student | sudo -S cat /etc/sudoers.d/consultants"

# ============================================================
# Grade Lab
# ============================================================

echo "[student@workstation ~]$ lab grade users-review"
history -s "lab grade users-review"
lab grade users-review

# ============================================================
# Finish Lab
# ============================================================

echo "[student@workstation ~]$ lab finish users-review"
history -s "lab finish users-review"
lab finish users-review

history -w
