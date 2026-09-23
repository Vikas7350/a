#!/bin/bash

clear

clean_history() {
    history -w
    local tmp
    tmp=$(mktemp)

    grep -vEi \
    '(curl|chmod|source|python|pynput|passwd-automation|cli-desktop\.sh|files-make\.sh|help-manual\.sh|help-review\.sh|edit-editfile\.sh|edit-bashconfig\.sh|edit-review\.sh|users-superuser\.sh|users-user\.sh|users-group\.sh|perms-default|perms-review|processes-control|processes-review|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history
    history -c
    history -r
}

clean_history

echo "[student@workstation ~]$ lab start processes-review"
history -s "lab start processes-review"
lab start processes-review

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

ssh student@serverb "mkdir -p /home/student/bin"

ssh student@serverb 'cat > /home/student/bin/process101 <<'"'"'EOF'"'"'
#!/bin/bash
while true
do
  var=1
  while (( var < 50000 ))
  do
    var=$(( var + 1 ))
  done
  sleep 1
done
EOF'

ssh student@serverb "chmod +x /home/student/bin/process101"

echo "[student@serverb ~]$ ls -l ~/bin/process101"
history -s "ls -l ~/bin/process101"
ssh student@serverb "ls -l /home/student/bin/process101"

echo "[student@serverb ~]$ nproc"
history -s "nproc"
ssh student@serverb "nproc"

echo "[student@serverb ~]$ ~/bin/process101 &"
history -s "~/bin/process101 &"
ssh student@serverb "nohup /home/student/bin/process101 >/dev/null 2>&1 &"

sleep 3

PID101=$(ssh student@serverb \
"pgrep -u student -f '^/bin/bash /home/student/bin/process101$' | head -n 1")

echo "[student@serverb ~]$ ps -p $PID101 -o pid,stat,cmd"
history -s "ps -p $PID101 -o pid,stat,cmd"
ssh student@serverb "ps -p $PID101 -o pid,stat,cmd"

echo
echo "[top]"
echo "Open another terminal and run:"
echo "ssh student@serverb"
echo "top"
echo

ssh student@serverb 'cp /home/student/bin/process101 /home/student/bin/process102'
ssh student@serverb "sed -i 's/50000/100000/' /home/student/bin/process102"
ssh student@serverb "chmod +x /home/student/bin/process102"

echo "[student@serverb ~]$ ~/bin/process102 &"
history -s "~/bin/process102 &"
ssh student@serverb "nohup /home/student/bin/process102 >/dev/null 2>&1 &"

sleep 3

PID102=$(ssh student@serverb \
"pgrep -u student -f '^/bin/bash /home/student/bin/process102$' | head -n 1")

echo "[student@serverb ~]$ ps -p $PID102 -o pid,stat,cmd"
history -s "ps -p $PID102 -o pid,stat,cmd"
ssh student@serverb "ps -p $PID102 -o pid,stat,cmd"

ssh student@serverb 'cp /home/student/bin/process101 /home/student/bin/process103'
ssh student@serverb "sed -i 's/50000/800000/' /home/student/bin/process103"
ssh student@serverb "chmod +x /home/student/bin/process103"

echo "[student@serverb ~]$ ~/bin/process103 &"
history -s "~/bin/process103 &"
ssh student@serverb "nohup /home/student/bin/process103 >/dev/null 2>&1 &"

sleep 10

PID103=$(ssh student@serverb \
"pgrep -u student -f '^/bin/bash /home/student/bin/process103$' | head -n 1")

echo "[student@serverb ~]$ ps -eo pid,stat,pcpu,cmd -u student"
history -s "ps -eo pid,stat,pcpu,cmd -u student"
ssh student@serverb \
"ps -eo pid,stat,pcpu,cmd -u student | grep -E 'process10[123]' | grep -v grep"

echo
echo "[student@serverb ~]$ kill -STOP $PID101"
history -s "kill -STOP $PID101"
ssh student@serverb "kill -STOP $PID101"

sleep 2

echo "[student@serverb ~]$ ps -p $PID101 -o pid,stat,cmd"
history -s "ps -p $PID101 -o pid,stat,cmd"
ssh student@serverb "ps -p $PID101 -o pid,stat,cmd"

echo "[student@serverb ~]$ kill -CONT $PID101"
history -s "kill -CONT $PID101"
ssh student@serverb "kill -CONT $PID101"

sleep 2

echo "[student@serverb ~]$ kill $PID101 $PID102 $PID103"
history -s "kill $PID101 $PID102 $PID103"
ssh student@serverb "kill $PID101 $PID102 $PID103 2>/dev/null || true"

sleep 3

echo "[student@serverb ~]$ ps -eo pid,stat,pcpu,cmd -u student"
history -s "ps -eo pid,stat,pcpu,cmd -u student"
ssh student@serverb \
"ps -eo pid,stat,pcpu,cmd -u student | grep -E 'process10[123]' | grep -v grep || echo 'No process101, process102, or process103 processes running'"

ssh student@serverb \
"pkill -u student -f '/home/student/bin/process101' 2>/dev/null || true"

ssh student@serverb \
"pkill -u student -f '/home/student/bin/process102' 2>/dev/null || true"

ssh student@serverb \
"pkill -u student -f '/home/student/bin/process103' 2>/dev/null || true"

echo "[student@serverb ~]$ rm -f ~/bin/process101 ~/bin/process102 ~/bin/process103"
history -s "rm -f ~/bin/process101 ~/bin/process102 ~/bin/process103"
ssh student@serverb "rm -f /home/student/bin/process101 /home/student/bin/process102 /home/student/bin/process103"

echo "[student@serverb ~]$ exit"
history -s "exit"
echo "logout"
echo "Connection to serverb closed."

cd "$HOME"

echo "[student@workstation ~]$ lab grade processes-review"
history -s "lab grade processes-review"
lab grade processes-review

echo "[student@workstation ~]$ lab finish processes-review"
history -s "lab finish processes-review"
lab finish processes-review

cd "$HOME"

history -w
