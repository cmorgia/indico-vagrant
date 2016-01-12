# Stop and disable Firewall
sudo systemctl stop firewalld
sudo systemctl disable firewalld

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

# start Indico
sudo zdaemon -C etc/zdctl.conf start
sudo indico db prepare


# Give Vagrant user I/O permissions 
chown -R vagrant /opt/indico

#cp /vagrant/apache_indico.conf /etc/httpd/conf.d/
#service httpd restart
