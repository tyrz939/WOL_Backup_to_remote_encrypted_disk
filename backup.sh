#!/bin/bash

#MAC address for WOL to wake the PC
etherwake xx:xx:xx:xx:xx:xx

#keyfile string used to decrypt drive
PASSPHRASE='PASSPHRASE_FOR_LUKS'

#Backup Server Address/User
HOST=xxxx
USERNAME="xxxx"

#Path on local NAS to backup with trailing slash
BACKUP_PATH="/path/to/backup/on/nas/"

#Wait for host to be up
echo 'Waiting for server to come up...'
while ! ping -c 1 -n -w 1 $HOST &> /dev/null; do true; done
echo 'Server is UP, giving 10 seconds to load services...'
#Sleep 30 sec to let processes finish loading on server
sleep 30

echo "Connecting to server"
ssh $USERNAME@$HOST << EOF
 echo "Mounting drive"
 #CHANGE TO SUIT YOUR SETUP
 echo '$PASSPHRASE' | sudo cryptsetup luksOpen /dev/sdz1 backup_hdd
 sudo mount /dev/mapper/backup_hdd /media/backup_hdd
EOF

echo "Run rsync"
rsync -avzr --delete -P -e ssh $BACKUP_PATH $USERNAME@$HOST:/media/backup3tb/Stuff

echo "Unmount the drive"
ssh $USERNAME@$HOST << EOF
 #CHANGE TO SUIT YOUR SETUP
 sudo umount /media/backup_hdd
 sudo cryptsetup luksClose /dev/mapper/backup_hdd
 sudo shutdown 1
EOF
