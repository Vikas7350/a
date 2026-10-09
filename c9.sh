```bash
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
    '(ssh-review|ssh-keygen|ssh-copy-id|sshd_config|authorized_keys|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history
    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start ssh-review"
history -s "lab start ssh-review"
lab start ssh-review

# ============================================================
# Step 1: Connect to servera
# ============================================================

echo ""
echo "[student@workstation ~]$ ssh student@servera"
history -s "ssh student@servera"

ssh student@servera

# ============================================================
# Step 2: Switch to production1 on servera
# ============================================================

echo ""
echo "On servera, run:"
echo "su - production1"
echo "Password: redhat"
echo ""
echo "Then continue with the following commands."
echo ""

# ============================================================
# Step 3: Generate passphrase-less SSH keys
# Run as production1 on servera
# ============================================================

echo "[production1@servera ~]$ ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519"
echo ""
echo "Run:"
echo "ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519"

# ============================================================
# Step 4: Copy public key to production1 on serverb
# Run as production1 on servera
# ============================================================

echo ""
echo "[production1@servera ~]$ ssh-copy-id production1@serverb"
echo "Enter password: redhat"

# ============================================================
# Step 5: Verify key-based login
# Run as production1 on servera
# ============================================================

echo ""
echo "[production1@servera ~]$ ssh production1@serverb"
echo "Verify that login succeeds without asking for a password."
echo "Then run exit to return to servera."
echo ""

# ============================================================
# Step 6: Configure sshd on serverb
# ============================================================

echo "On serverb, become root:"
echo "su - root"
echo "Password: redhat"
echo ""

echo "Edit the SSH server configuration:"
echo "vi /etc/ssh/sshd_config"
echo ""
echo "Set or add these directives:"
echo "PermitRootLogin no"
echo "PasswordAuthentication no"
echo "PubkeyAuthentication yes"
echo ""
echo "Save the file and validate it:"
echo "sshd -t"
echo ""
echo "Restart sshd:"
echo "systemctl restart sshd"
echo ""

# ============================================================
# Step 7: Verify configuration on serverb
# ============================================================

echo "Run on serverb as root:"
echo "sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'"
echo ""
echo "Expected:"
echo "permitrootlogin no"
echo "passwordauthentication no"
echo "pubkeyauthentication yes"

# ============================================================
# Step 8: Return to workstation
# ============================================================

echo ""
echo "Exit the root shell and SSH sessions until you return to workstation."
echo ""

# ============================================================
# Step 9: Grade Lab
# ============================================================

echo "[student@workstation ~]$ lab grade ssh-review"
history -s "lab grade ssh-review"
lab grade ssh-review

# ============================================================
# Step 10: Finish Lab
# ============================================================

echo ""
echo "[student@workstation ~]$ cd ~"
cd ~

echo "[student@workstation ~]$ lab finish ssh-review"
history -s "lab finish ssh-review"
lab finish ssh-review

# ============================================================
# Save history
# ============================================================

history -w
```
