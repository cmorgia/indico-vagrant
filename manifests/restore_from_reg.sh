#!/bin/bash

export BACKUP_FILE=$(ssh -q reg "cd /opt/new/indico-instance/backup ; ls -1tr | tail -1")

if [ ! -d "/opt/indico/backup" ]; then
	mkdir -p /opt/indico/backup
fi

scp reg:/opt/new/indico-instance/backup/$BACKUP_FILE /opt/indico/backup

exec $(dirname $0)/restore.sh $BACKUP_FILE
