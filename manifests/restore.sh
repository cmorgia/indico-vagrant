#!/bin/bash

cd /vagrant/opt
source bin/activate

export BACKUP_FILE=$1
export BACKUP_NAME=$(basename $BACKUP_FILE .zip)

/vagrant/opt/indico-src/bin/unog/restore.sh -p $BACKUP_FILE -force
/vagrant/opt/indico-src/bin/unog/restore.sh -r $BACKUP_NAME -force