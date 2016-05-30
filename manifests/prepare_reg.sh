#!/bin/bash

# Create the ssh keys
cat /dev/zero | ssh-keygen -q -N ""

CONFIG=1

if [ -f ~/.ssh/config ]; then
	grep -q "Host reg" < ~/.ssh/config
	CONFIG=$?
fi

if [ "$CONFIG"=="1" ]; then
cat << EOF >>~/.ssh/config
Host reg
	HostName reg.unog.ch
	User root
EOF
fi

chmod g-rw ~/.ssh/config

ssh-keyscan reg.unog.ch >> ~/.ssh/known_hosts

ssh -o PasswordAuthentication=no reg ls >/dev/null 2>&1

if [ $? -ne 0 ]; then
	echo "Please prepare to input the 'root' password for REG"
	cat ~/.ssh/id_rsa.pub | ssh reg "cat - >>~/.ssh/authorized_keys"
fi

ssh -o PasswordAuthentication=no reg ls >/dev/null 2>&1

if [ $? -eq 0 ]; then
	echo "SSH successfully configured"
else
	echo "SSH configuration unsuccessful"
fi
