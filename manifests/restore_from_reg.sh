#!/bin/bash

cd /vagrant/opt
source bin/activate

BACKUP_FILE=$(ssh -q reg "cd /opt/new/indico-instance/backup ; ls -1tr | tail -1")
BACKUP_NAME=$(basename $BACKUP_FILE .zip)

if [ ! -d "/opt/indico/backup" ]; then
	mkdir -p /opt/indico/backup
fi

scp reg:/opt/new/indico-instance/backup/$BACKUP_FILE /opt/indico/backup

/vagrant/opt/indico-src/bin/unog/restore.sh -p $BACKUP_FILE -force
/vagrant/opt/indico-src/bin/unog/restore.sh -r $BACKUP_NAME -force
