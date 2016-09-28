#Disable IPv6

grep net.ipv6.conf.all.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)
grep net.ipv6.conf.default.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)
grep net.ipv6.conf.lo.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)

sysctl -pip

# Install development tools
sudo yum -y group install "Development Tools"

# Install Epel package
sudo yum -y install epel-release

# Install Redis
sudo yum -y install redis php-pecl-redis

# Install setuptools
sudo yum -y install python-pip

# Upgrade pip
sudo pip install --upgrade pip

# Install other dev libs required by Indico
sudo yum -y install psmisc zlib-devel openssl-devel bzip2-devel python-devel freetds-devel
sudo yum -y install libxml2-devel libxslt-devel libffi-devel libjpeg-devel
sudo yum -y install mod_wsgi mod_xsendfile tex cups cups-client cups-devel
sudo yum -y install nodejs npm vim mod_ssl

# Install some missing stuff for PDF on-the-fly generation
sudo cp -R /vagrant/packages/commonstaff /usr/share/texlive/texmf/tex/latex/
sudo texhash

# Install Apache
sudo yum -y install httpd httpd-devel

# Install additional fonts
rpm -i http://li.nux.ro/download/nux/dextop/el7/x86_64/webcore-fonts-3.0-1.noarch.rpm

# Install and configure Postgresql 9.4
sudo yum -y localinstall http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-2.noarch.rpm
sudo yum -y install postgresql94-server postgresql94-devel postgresql94-contrib
sudo /usr/pgsql-9.4/bin/postgresql94-setup initdb
sudo cp -f /vagrant/confs/pg_hba.conf /var/lib/pgsql/9.4/data/pg_hba.conf
sudo chkconfig postgresql-9.4 on
export PATH=/usr/pgsql-9.4/bin/:$PATH


# Install and setup VirtualEnv
sudo pip install virtualenv
virtualenv /vagrant/opt

# start virtualenv
source /vagrant/opt/bin/activate

# Install Celery and Redis bundle
pip install -U celery[redis]

# Those old versions are needed by Indico
pip install redis==2.10.3
pip install pytz==2014.10
# ZEO 5.0.0 will require python 2.7.9
pip install ZEO==4.2.0 

# Download and install Maildump
#sudo pip install maildump
#sudo pip install --upgrade webassets

# Download latest Indico from github
git config --global url.https://github.com/.insteadOf git://github.com/

if cd /vagrant/opt/indico-src ; then git pull ; else git clone https://github.com/dcmits/indico-unog.git /vagrant/opt/indico-src; fi

sudo mkdir /opt/indico
sudo chown vagrant /opt/indico
cd /vagrant/opt/indico-src

cd ext_modules
rm -rf node_env
cd -

python setup.py develop

# Install Indico's requirements and deps
pip install requests
env "PATH=$PATH" pip install -r requirements.txt
pip install -r requirements.dev.txt

fab setup_deps

echo "/opt/indico" | python setup.py develop_config
yes | cp /vagrant/confs/etc/*.conf /vagrant/opt/indico-src/etc/
yes | cp /vagrant/confs/99-forensic.conf /etc/httpd/conf.modules.d/
yes | cp /vagrant/confs/apache-indico-example.conf /etc/httpd/conf.d/indico.conf
yes | cp -R /vagrant/confs/ssl /etc/httpd
yes | cp /vagrant/manifests/run_indico.sh /vagrant/opt/
yes | cp /vagrant/manifests/restore_from_reg.sh /vagrant/opt/
chmod 777 /vagrant/opt/run_indico.sh /vagrant/opt/restore_from_reg.sh
sudo chown -R vagrant /opt/indico

# Install default plugins
mkdir -p /vagrant/opt/indico-plugins
cd /vagrant/opt/indico-plugins

declare -A plugins
plugins[unogshorttitle]="https://github.com/dcmits/unog-shorttitle.git"
plugins[search]="https://github.com/dcmits/search"
plugins[searchunog]="https://github.com/dcmits/search_unog.git"
plugins[unogtags]="https://github.com/dcmits/unog-tags.git"
plugins[indicopassbooks]="https://github.com/dcmits/indico-passbooks.git"
plugins[unoggmeetssync]="https://github.com/dcmits/unog-gmeetssync.git"
plugins[unogfloatingheader]="https://github.com/dcmits/unog-floatingheader.git"
plugins[unogsystemlinks]="https://github.com/dcmits/unog-systemlinks.git"
plugins[indicoulogger]="https://github.com/dcmits/indico-ulogger.git"


for plugin in "${!plugins[@]}" ; do
	if [ -d "/vagrant/opt/indico-plugins/$plugin" ] ; then cd /vagrant/opt/indico-plugins/$plugin ; git pull ; else git clone "${plugins[$plugin]}" /vagrant/opt/indico-plugins/$plugin ; cd /vagrant/opt/indico-plugins/$plugin ; fi
    python setup.py develop
done




