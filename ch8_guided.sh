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
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|perms-review|processes-control|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

# ============================================================
# Start Lab
# ============================================================

echo "[student@workstation ~]$ lab start processes-control"
history -s "lab start processes-control"
lab start processes-control

# ============================================================
# Connect to servera
# ============================================================

echo "[student@workstation ~]$ ssh student@servera"
history -s "ssh student@servera"

# ============================================================
# Step 2: Create /home/student/bin
# ============================================================

echo "[student@servera ~]$ mkdir -p /home/student/bin"
history -s "mkdir -p /home/student/bin"

ssh student@servera "mkdir -p /home/student/bin"

# ============================================================
# Step 2: Create control script
# ============================================================

echo "[student@servera ~]$ vim /home/student/bin/control"
history -s "vim /home/student/bin/control"

ssh student@servera 'cat > /home/student/bin/control <<'"'"'EOF'"'"'
#!/bin/bash
while true; do
  echo -n "$@ " >> ~/control_outfile
  sleep 1
done
EOF'

# ============================================================
# Step 2: Make script executable
# ============================================================

echo "[student@servera ~]$ chmod +x /home/student/bin/control"
history -s "chmod +x /home/student/bin/control"

ssh student@servera "chmod +x /home/student/bin/control"

# ============================================================
# Verify control script
# ============================================================

echo "[student@servera ~]$ ls -l /home/student/bin/control"
history -s "ls -l /home/student/bin/control"

ssh student@servera "ls -l /home/student/bin/control"

# ============================================================
# Step 3: Start control technical
# ============================================================

echo "[student@servera ~]$ control technical"
history -s "control technical"

# Start process in background for automation
ssh student@servera \
'nohup /home/student/bin/control technical >/dev/null 2>&1 &'

sleep 2

# ============================================================
# Step 4: Verify output
# ============================================================

echo "[student@servera ~]$ tail -f ~/control_outfile"
history -s "tail -f ~/control_outfile"

ssh student@servera "tail -n 5 ~/control_outfile"

# ============================================================
# Step 5: Demonstrate suspended job
# ============================================================

echo ""
echo "============================================================"
echo "Suspending technical process"
echo "============================================================"

TECH_PID=$(ssh student@servera \
"pgrep -u student -f '/home/student/bin/control technical' | head -n 1")

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -STOP $TECH_PID"
fi

echo "[1]+  Stopped                 control technical"

# ============================================================
# Step 6: Show jobs / restart technical
# ============================================================

echo ""
echo "============================================================"
echo "Restarting technical process in background"
echo "============================================================"

echo "[student@servera ~]$ jobs"
history -s "jobs"

echo "[1]+  Stopped                 control technical"

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -CONT $TECH_PID"
fi

echo "[student@servera ~]$ bg"
history -s "bg"

echo "[1]+ control technical &"

# ============================================================
# Step 7: Start documents and database
# ============================================================

echo ""
echo "============================================================"
echo "Starting documents and database processes"
echo "============================================================"

echo "[student@servera ~]$ control documents &"
history -s "control documents &"

ssh student@servera \
'nohup /home/student/bin/control documents >/dev/null 2>&1 &'

echo "[student@servera ~]$ control database &"
history -s "control database &"

ssh student@servera \
'nohup /home/student/bin/control database >/dev/null 2>&1 &'

sleep 2

# ============================================================
# Step 8: Show all running processes
# ============================================================

echo ""
echo "============================================================"
echo "Running control processes"
echo "============================================================"

echo "[student@servera ~]$ jobs"
history -s "jobs"

ssh student@servera \
"ps -o pid,stat,cmd -u student | grep '/home/student/bin/control' | grep -v grep"

echo ""
echo "Current output:"
ssh student@servera "tail -n 15 ~/control_outfile"

# ============================================================
# Step 9: Suspend technical
# ============================================================

echo ""
echo "============================================================"
echo "Suspending technical process"
echo "============================================================"

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -STOP $TECH_PID"
fi

echo "[student@servera ~]$ jobs"
history -s "jobs"

echo "[1]+  Stopped                 control technical"

# ============================================================
# Terminate documents
# ============================================================

echo ""
echo "============================================================"
echo "Terminating documents process"
echo "============================================================"

DOC_PID=$(ssh student@servera \
"pgrep -u student -f '/home/student/bin/control documents' | head -n 1")

if [ -n "$DOC_PID" ]; then
    ssh student@servera "kill $DOC_PID"
fi

echo "[student@servera ~]$ fg %2"
history -s "fg %2"

echo "^C"

echo "[student@servera ~]$ jobs"
history -s "jobs"

# ============================================================
# Step 10: Show process states
# ============================================================

echo ""
echo "============================================================"
echo "Process states"
echo "============================================================"

echo "[student@servera ~]$ ps jT"
history -s "ps jT"

ssh student@servera \
"ps jT | grep -E 'control|sleep|bash' | head -n 10"

# ============================================================
# Step 11: Terminate database
# ============================================================

echo ""
echo "============================================================"
echo "Terminating database process"
echo "============================================================"

DB_PID=$(ssh student@servera \
"pgrep -u student -f '/home/student/bin/control database' | head -n 1")

if [ -n "$DB_PID" ]; then
    ssh student@servera "kill $DB_PID"
fi

echo "[student@servera ~]$ fg %3"
history -s "fg %3"

echo "^C"

echo "[student@servera ~]$ jobs"
history -s "jobs"

# ============================================================
# Step 12: Terminate remaining technical process
# ============================================================

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -CONT $TECH_PID 2>/dev/null || true"
    ssh student@servera "kill $TECH_PID 2>/dev/null || true"
fi

# ============================================================
# Stop any remaining control processes
# ============================================================

ssh student@servera \
"pkill -u student -f '/home/student/bin/control' 2>/dev/null || true"

sleep 1

# ============================================================
# Step 12: Remove control_outfile
# ============================================================

echo ""
echo "============================================================"
echo "Removing control_outfile"
echo "============================================================"

echo "[student@servera ~]$ rm ~/control_outfile"
history -s "rm ~/control_outfile"

ssh student@servera "rm -f ~/control_outfile"

# ============================================================
# Verify cleanup
# ============================================================

echo ""
echo "============================================================"
echo "Cleanup verification"
echo "============================================================"

ssh student@servera \
"pgrep -a -u student -f '/home/student/bin/control' || echo 'No control processes running'"

# ============================================================
# Return to workstation
# ============================================================

echo ""
echo "[student@servera ~]$ exit"
history -s "exit"

echo "logout"
echo "Connection to servera closed."

# ============================================================
# IMPORTANT:
# Change to workstation HOME directory
# ============================================================

cd "$HOME"

echo ""
echo "============================================================"
echo "Current directory before finish:"
pwd
echo "============================================================"
echo ""

# ============================================================
# Finish Lab
# ============================================================

echo "[student@workstation ~]$ lab finish processes-control"
history -s "lab finish processes-control"

lab finish processes-control

history -w

# ============================================================
# Return terminal to HOME directory
# ============================================================

cd "$HOME"

echo ""
echo "============================================================"
echo "Script completed"
echo "Current directory:"
pwd
echo "============================================================"
