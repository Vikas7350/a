#!/bin/bash

clear

lab start users-review

sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb "sudo -S bash -s" <<'REMOTE'
student

sed -i 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   30/' /etc/login.defs

groupadd -g 35000 consultants

echo '%consultants ALL=(ALL) ALL' > /etc/sudoers.d/consultants
chmod 440 /etc/sudoers.d/consultants

useradd -G consultants consultant1
useradd -G consultants consultant2
useradd -G consultants consultant3

echo 'consultant1:redhat' | chpasswd
echo 'consultant2:redhat' | chpasswd
echo 'consultant3:redhat' | chpasswd

EXPIRY_DATE=$(date -d "+90 days" +%F)

chage -E "$EXPIRY_DATE" consultant1
chage -E "$EXPIRY_DATE" consultant2
chage -E "$EXPIRY_DATE" consultant3

chage -M 15 consultant2

chage -d 0 consultant1
chage -d 0 consultant2
chage -d 0 consultant3

REMOTE

clear

lab grade users-review

lab finish users-review
