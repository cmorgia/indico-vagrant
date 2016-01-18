# Stop and disable Firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Enable Postgresql to listen on all IP
DPATH="/var/lib/pgsql/9.4/data/postgresql.conf"
OLD="#listen_addresses = 'localhost'"
NEW="listen_addresses = '*'"
sed -i.bak "s/$OLD/$NEW/g" $DPATH

# Start Postgresql
sudo service postgresql-9.4 start
sudo createuser -s root -U postgres
sudo createdb indico -U postgres

# Start Redis
sudo service redis start
sudo systemctl enable redis.service

# move to Indico 
cd /vagrant/opt/indico-src

# generate new SecretKey
OLD="SecretKey = ''"
SECRET=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
NEW="SecretKey = '$SECRET'"
DPATH="etc/indico.conf"
sed -i.bak "s/$OLD/$NEW/g" $DPATH

# Give Vagrant user I/O permissions 
sudo chown -R vagrant /opt/indico

# First time start Indico: Init Postgresql DB
/vagrant/opt/bin/zdaemon -C etc/zdctl.conf start
/vagrant/opt/bin/indico db prepare
/vagrant/opt/bin/zdaemon -C etc/zdctl.conf stop


# deactivate virtualenv
deactivate





#cp /vagrant/apache_indico.conf /etc/httpd/conf.d/
#service httpd restart
