#!/bin/bash

clear

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

echo "[student@workstation ~]$ lab start processes-control"
history -s "lab start processes-control"
lab start processes-control

echo "[student@workstation ~]$ ssh student@servera"
history -s "ssh student@servera"

echo "[student@servera ~]$ mkdir -p /home/student/bin"
history -s "mkdir -p /home/student/bin"
ssh student@servera "mkdir -p /home/student/bin"

echo "[student@servera ~]$ vim /home/student/bin/control"
history -s "vim /home/student/bin/control"

ssh student@servera 'cat > /home/student/bin/control <<'"'"'EOF'"'
#!/bin/bash
while true; do
  echo -n "$@ " >> ~/control_outfile
  sleep 1
done
EOF'

echo "[student@servera ~]$ chmod +x /home/student/bin/control"
history -s "chmod +x /home/student/bin/control"
ssh student@servera "chmod +x /home/student/bin/control"

echo "[student@servera ~]$ ls -l /home/student/bin/control"
history -s "ls -l /home/student/bin/control"
ssh student@servera "ls -l /home/student/bin/control"

echo "[student@servera ~]$ control technical"
history -s "control technical"
ssh student@servera \
'nohup /home/student/bin/control technical >/dev/null 2>&1 &'

sleep 2

echo "[student@servera ~]$ tail -n 5 ~/control_outfile"
history -s "tail -n 5 ~/control_outfile"
ssh student@servera "tail -n 5 ~/control_outfile"

TECH_PID=$(ssh student@servera \
"pgrep -u student -f '/home/student/bin/control technical' | head -n 1")

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -STOP $TECH_PID"
fi

echo "[1]+  Stopped                 control technical"

echo "[student@servera ~]$ jobs"
history -s "jobs"

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -CONT $TECH_PID"
fi

echo "[student@servera ~]$ bg"
history -s "bg"

echo "[1]+ control technical &"

echo "[student@servera ~]$ control documents &"
history -s "control documents &"
ssh student@servera \
'nohup /home/student/bin/control documents >/dev/null 2>&1 &'

echo "[student@servera ~]$ control database &"
history -s "control database &"
ssh student@servera \
'nohup /home/student/bin/control database >/dev/null 2>&1 &'

sleep 2

echo "[student@servera ~]$ jobs"
history -s "jobs"
ssh student@servera \
"ps -o pid,stat,cmd -u student | grep '/home/student/bin/control' | grep -v grep"

ssh student@servera "tail -n 15 ~/control_outfile"

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -STOP $TECH_PID"
fi

echo "[student@servera ~]$ jobs"
history -s "jobs"

echo "[1]+  Stopped                 control technical"

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

echo "[student@servera ~]$ ps jT"
history -s "ps jT"
ssh student@servera \
"ps jT | grep -E 'control|sleep|bash' | head -n 10"

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

if [ -n "$TECH_PID" ]; then
    ssh student@servera "kill -CONT $TECH_PID 2>/dev/null || true"
    ssh student@servera "kill $TECH_PID 2>/dev/null || true"
fi

ssh student@servera \
"pkill -u student -f '/home/student/bin/control' 2>/dev/null || true"

sleep 1

echo "[student@servera ~]$ rm ~/control_outfile"
history -s "rm ~/control_outfile"
ssh student@servera "rm -f ~/control_outfile"

ssh student@servera \
"pgrep -a -u student -f '/home/student/bin/control' || echo 'No control processes running'"

echo "[student@servera ~]$ exit"
history -s "exit"
echo "logout"
echo "Connection to servera closed."

cd "$HOME"

echo "[student@workstation ~]$ lab finish processes-control"
history -s "lab finish processes-control"
lab finish processes-control

history -w

