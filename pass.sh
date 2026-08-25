#!/bin/bash

set -e

echo "========================================"
echo " Starting users-password lab"
echo "========================================"

# Start the lab
lab start users-password

echo
echo "========================================"
echo " Connecting to servera"
echo "========================================"

sshpass -p student ssh -o StrictHostKeyChecking=no student@servera <<'REMOTE'

echo "========================================"
echo " Configuring operator1"
echo "========================================"

# Lock operator1
echo "[1] Locking operator1..."
echo "student" | sudo -S usermod -L operator1

# Unlock operator1
echo "[2] Unlocking operator1..."
echo "student" | sudo -S usermod -U operator1

# Set password maximum age to 90 days
echo "[3] Setting password maximum age to 90 days..."
echo "student" | sudo -S chage -M 90 operator1

# Force password change on first login
echo "[4] Forcing password change on first login..."
echo "student" | sudo -S chage -d 0 operator1

# Calculate expiry date 180 days from today
EXPIRY_DATE=$(date -d "+180 days" +%F)

echo "[5] Setting account expiry to $EXPIRY_DATE..."
echo "student" | sudo -S chage -E "$EXPIRY_DATE" operator1

# Set default password expiration for new users
echo "[6] Setting PASS_MAX_DAYS to 180..."
echo "student" | sudo -S sed -i \
's/^[[:space:]]*PASS_MAX_DAYS[[:space:]].*/PASS_MAX_DAYS   180/' \
/etc/login.defs

# Change operator1 password automatically
echo "[7] Changing operator1 password..."

# Use chpasswd to set the password
echo "student" | sudo -S chage -d 0 operator1
echo "student" | sudo -S bash -c 'echo "operator1:forsooth123" | chpasswd'

# Since chpasswd changes the password, force the password change flag
# is cleared automatically, so set it again if required by the lab.
# The lab's required final password is forsooth123.
echo "student" | sudo -S chage -M 90 operator1
echo "student" | sudo -S chage -E "$EXPIRY_DATE" operator1

echo
echo "========================================"
echo " Verification"
echo "========================================"

echo "student" | sudo -S chage -l operator1

echo
echo "PASS_MAX_DAYS:"
grep '^PASS_MAX_DAYS' /etc/login.defs

echo
echo "========================================"
echo " servera configuration complete"
echo "========================================"

REMOTE

echo
echo "========================================"
echo " Finishing users-password lab"
echo "========================================"

lab finish users-password

echo
echo "========================================"
echo " LAB COMPLETED"
echo "========================================"
