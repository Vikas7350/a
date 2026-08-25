#!/bin/bash

set -e

lab start users-password

sshpass -p student ssh -o StrictHostKeyChecking=no student@servera <<'REMOTE'

echo "student" | sudo -S usermod -L operator1
echo "student" | sudo -S usermod -U operator1
echo "student" | sudo -S chage -M 90 operator1
echo "student" | sudo -S chage -d 0 operator1

EXPIRY_DATE=$(date -d "+180 days" +%F)

echo "student" | sudo -S chage -E "$EXPIRY_DATE" operator1

echo "student" | sudo -S sed -i 's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   180/' /etc/login.defs

echo "student" | sudo -S bash -c 'echo "operator1:forsooth123" | chpasswd'

echo "student" | sudo -S chage -M 90 operator1
echo "student" | sudo -S chage -E "$EXPIRY_DATE" operator1

echo "student" | sudo -S chage -l operator1

REMOTE

lab finish users-password
