#!/bin/bash

export BACKUP_FILE=$1
export BACKUP_NAME=$(basename $BACKUP_FILE)

if [ ! -d "/opt/indico/backup" ]; then
	mkdir -p /opt/indico/backup
fi

ln -sf $BACKUP_FILE /opt/indico/backup/

$(dirname $0)/restore.sh $BACKUP_NAME

rm -f /opt/indico/backup/$BACKUP_NAME