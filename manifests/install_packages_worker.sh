#Disable IPv6

grep net.ipv6.conf.all.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)
grep net.ipv6.conf.default.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)
grep net.ipv6.conf.lo.disable_ipv6 /etc/sysctl.conf || (echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf)

# Upgrade pip
sudo pip install --upgrade pip

# Install other dev libs required by Indico
sudo yum -y install nodejs npm vim mod_ssl

# setup VirtualEnv
sudo virtualenv /data/opt
sudo chown -R indico /data/opt

# activate by default
echo "source /vagrant/opt/bin/activate" >> /home/indico/.bash_profile

# start virtualenv
source /vagrant/opt/bin/activate

# Install xlc creators
pip install xlrd docxtpl openpyxl

# Config github
git config --global url.https://github.com/.insteadOf git://github.com/

# Ask for github login/pass
echo -n "Enter Github Username and press [ENTER]: "
read gituser
read -s -p "Enter Password: " gitpass


git clone https://$gituser:$gitpass@github.com/dcmits/indico-unog.git /data/opt/indico-src

