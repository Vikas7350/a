#!/bin/bash

clear

clean_history() {
    history -w

    local tmp
    tmp=$(mktemp)

    grep -vEi \
    '(curl|chmod|source|python|pynput|passwd-automation|users-review\.sh|users-password\.sh|users-group\.sh|files-make\.sh|history)' \
    ~/.bash_history > "$tmp"

    mv "$tmp" ~/.bash_history

    history -c
    history -r
}

clean_history

echo "[student@workstation ~]$ lab start rhcsa-rh124-review1"
history -s "lab start rhcsa-rh124-review1"
lab start rhcsa-rh124-review1

echo "[student@workstation ~]$ ssh student@serverb"
history -s "ssh student@serverb"

echo "[student@serverb ~]$ mkdir -p /home/student/grading"
history -s "mkdir -p /home/student/grading"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"mkdir -p /home/student/grading"

echo "[student@serverb ~]$ touch /home/student/grading/grade1 /home/student/grading/grade2 /home/student/grading/grade3"
history -s "touch /home/student/grading/grade1 /home/student/grading/grade2 /home/student/grading/grade3"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"touch /home/student/grading/grade1 /home/student/grading/grade2 /home/student/grading/grade3"

echo "[student@serverb ~]$ head -n 5 /home/student/bin/manage > /home/student/grading/review.txt"
history -s "head -n 5 /home/student/bin/manage > /home/student/grading/review.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"head -n 5 /home/student/bin/manage > /home/student/grading/review.txt"

echo "[student@serverb ~]$ tail -n 3 /home/student/bin/manage >> /home/student/grading/review.txt"
history -s "tail -n 3 /home/student/bin/manage >> /home/student/grading/review.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"tail -n 3 /home/student/bin/manage >> /home/student/grading/review.txt"

echo "[student@serverb ~]$ cp /home/student/grading/review.txt /home/student/grading/review-copy.txt"
history -s "cp /home/student/grading/review.txt /home/student/grading/review-copy.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"cp /home/student/grading/review.txt /home/student/grading/review-copy.txt"

echo "[student@serverb ~]$ sed -i '/Test JJ/ {p;}' /home/student/grading/review-copy.txt"
history -s "sed -i '/Test JJ/ {p;}' /home/student/grading/review-copy.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"sed -i '/Test JJ/ {p;}' /home/student/grading/review-copy.txt"

echo "[student@serverb ~]$ sed -i '/Test HH/d' /home/student/grading/review-copy.txt"
history -s "sed -i '/Test HH/d' /home/student/grading/review-copy.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"sed -i '/Test HH/d' /home/student/grading/review-copy.txt"

echo "[student@serverb ~]$ sed -i '/Test BB/a Level 1 Training' /home/student/grading/review-copy.txt"
history -s "sed -i '/Test BB/a Level 1 Training' /home/student/grading/review-copy.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"sed -i '/Test BB/a Level 1 Training' /home/student/grading/review-copy.txt"

echo "[student@serverb ~]$ ln /home/student/grading/grade1 /home/student/hardcopy"
history -s "ln /home/student/grading/grade1 /home/student/hardcopy"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"ln /home/student/grading/grade1 /home/student/hardcopy"

echo "[student@serverb ~]$ ln -s /home/student/grading/grade2 /home/student/softcopy"
history -s "ln -s /home/student/grading/grade2 /home/student/softcopy"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"ln -s /home/student/grading/grade2 /home/student/softcopy"

echo "[student@serverb ~]$ ls -l /boot > /home/student/grading/longlisting.txt"
history -s "ls -l /boot > /home/student/grading/longlisting.txt"
sshpass -p student ssh -o StrictHostKeyChecking=no student@serverb \
"ls -l /boot > /home/student/grading/longlisting.txt"

echo "[student@workstation ~]$ lab grade rhcsa-rh124-review1"
history -s "lab grade rhcsa-rh124-review1"
lab grade rhcsa-rh124-review1

echo "[student@workstation ~]$ lab finish rhcsa-rh124-review1"
history -s "lab finish rhcsa-rh124-review1"
lab finish rhcsa-rh124-review1

history -w
