# Run maildump
#if [ ! -f md.pid ]; then
#    maildump --http-ip 0.0.0.0 --smtp-ip 0.0.0.0 --smtp-port 8025 -p md.pid
#fi
cd /vagrant/opt
source bin/activate 

sudo chown -R vagrant /opt/indico

# Run Zeo
zdaemon -C /vagrant/opt/indico-src/etc/zdctl.conf restart

# Run Indico
indico runserver