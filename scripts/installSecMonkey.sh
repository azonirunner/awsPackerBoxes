#!/bin/bash 
set -e
set -x

# == update.sh ==========================================

# Update yum
echo "Running Yum Update"
sudo yum -y update

# Update .bash_profile
echo "updating the bash_profile"
sudo sed -i -e "\$a # ADDING PERSONALIZATION \nalias ll='ls -al'\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aset -o vi\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aexport HISTSIZE='5000'\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aexport HISTFILESIZE='10000'\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aexport SECURITY_MONKEY_SETTINGS='/home/ec2-user/security_monkey/env-config/config-deploy.py'\n" /home/ec2-user/.bash_profile

# maybe consider vim customizations

# == packageInstall.sh ==========================================

echo "installing packages for security monkey + gcc"
# using postgres93 and need gcc along with nginx and git"
sudo yum -y install nginx git postgresql93 postgresql93-devel postgresql93-server postgresql-contrib gcc

# NOTE: Extra work to get this to run on Amazon Linux
#       Need python27 for the grouping in some of the py
#       Need devel library for the py-bcrypt
#       OR NEED TO CHANGE PYTHON - watcher.py - using dictionary
echo "Installing python27 and devel "
sudo yum -y install python27 python27-devel.x86_64 

# NOTE: Need to install the python setup tools
echo "wget the pypi setuptools and install - for the python27"
wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg
sudo sh setuptools-0.6c11-py2.7.egg

echo "installing supervisor"
sudo easy_install supervisor

# == secMonkey.sh ==========================================

echo "Initializing postgres "
sudo service postgresql93 initdb
echo "Setting up postgresql to start at reboot"
sudo chkconfig postgresql93 on
echo "Turning postgres on as a service "
sudo service postgresql93 start

echo "sleeping 5 seconds"
sleep 5

# setup postgres user
# will want to change this password.
echo "---> start creating postgres user and setting password <---"
sudo -i -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'securitymonkeypassword';"
echo "---> start creating postgresql secmonkey DB <---"
sudo -i -u postgres createdb secmonkey

echo "---> updating postgresql pg_hba.conf and postgresql.conf <---"
sudo sed -i -e "\$ahost all  all    0.0.0.0/0  md5\n" /var/lib/pgsql93/data/pg_hba.conf
sudo sed -i -e '/^host/ s/ident/md5/' /var/lib/pgsql93/data/pg_hba.conf
sudo sed -i -e "\$alisten_addresses='*'\n" /var/lib/pgsql93/data/postgresql.conf 

# getting security monkey code
echo "---> cloning github NetFlix Security Monkey <---"
cd /home/ec2-user
mkdir /home/ec2-user/security_monkey
git clone https://github.com/Netflix/security_monkey.git /home/ec2-user/security_monkey
echo "---> chowning the ec2-user directory "
sudo chown -R ec2-user:ec2-user /home/ec2-user/*

echo "sleeping 5 seconds"
sleep 5

echo "---> change directory into security_monkey <---"
cd /home/ec2-user/security_monkey

echo "---> export SECURITY_MONKEY_SETTINGS <---"
export SECURITY_MONKEY_SETTINGS=/home/ec2-user/security_monkey/env-config/config-deploy.py

# python install of security monkey - note using python27
echo "INSTALL security monkey"
cd /home/ec2-user/security_monkey/
sudo python27 setup.py install

echo "---> chown AGAIN the ec2-user directory "
sudo chown -R ec2-user:ec2-user /home/ec2-user/*

# == setupNginx.sh ==========================================

# making ssl key and cert for nginx (security monkey)
echo "Creating SSL key and crt"
openssl genrsa -des3 -passout pass:yourpassword -out server.key 2048
openssl rsa -in server.key -out server.key.insecure -passin pass:yourpassword
mv server.key server.key.secure
mv server.key.insecure server.key

echo "signing crt"
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=AZ/L=TEMPE/O=InfoSec/OU=IT OPS/CN=ssomeccompany.com"
openssl x509 -req -days 365  -in server.csr -signkey server.key -out server.crt

echo "Copying certs to correct directories"
sudo chmod 600 server.key 
sudo mv server.crt /etc/ssl/certs/
sudo mkdir /etc/ssl/private
sudo mv server.key /etc/ssl/private/

# access logs for nginx server for security monkey.
sudo mkdir -p /var/log/nginx/log
sudo touch /var/log/nginx/log/securitymonkey.access.log
sudo touch /var/log/nginx/log/securitymonkey.error.log

# make sites directoriers for nginx
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled

# Tried setting installuser but kept showing as root instead of ec2-user.  
# in provisioner - have this set to execute as ec2-user so must not be understanding something
# INSTALLUSER=(`whoami`)
# modify /etc/nginx/nginx.conf to include sites-enabled for http module
sudo sed -i '/^http {/a\ \n    # Load modular config files from the \/etc\/nginx\/sites-enabled\n    include \/etc\/nginx\/sites-enabled\/*;\n' /etc/nginx/nginx.conf
# modify /etc/nginx/nginx.conf to make user be host user (ex - ec2-user)
#sudo sed -i -e '/^user/ s/nginx/'$INSTALLUSER'/' /etc/nginx/nginx.conf
sudo sed -i -e '/^user/ s/nginx/ec2-user/' /etc/nginx/nginx.conf

# copy the securitymonkey.conf to the sites-available
#sudo sed -i -e 's/\/home\/ubuntu/\/home\/'$INSTALLUSER'/' /tmp/securitymonkey.conf
sudo sed -i -e 's/\/home\/ubuntu/\/home\/ec2-user/' /tmp/securitymonkey.conf
cp /tmp/securitymonkey.conf /etc/nginx/sites-available/securitymonkey.conf

# symlink the security-monkey.conf to the sites-enabled directory
sudo ln -s /etc/nginx/sites-available/securitymonkey.conf /etc/nginx/sites-enabled/securitymonkey.conf
#sudo rm /etc/nginx/sites-enabled/default

echo "Starting nginx and set it up to always start"
sudo service nginx restart
sudo chkconfig nginx on

# == run db upgrade ============================================
echo "Starting postgres"
sudo service postgresql93 stop
sudo service postgresql93 start
echo "Update the database"
cd /home/ec2-user/security_monkey/
sudo -E python27 manage.py db upgrade
echo "---> chown AGAIN AGAIN the ec2-user directory "
sudo chown -R ec2-user:ec2-user /home/ec2-user/

# == supervisord.sh ==========================================
echo "cd into supervisor directory to run it"
cd /home/ec2-user/security_monkey/supervisor
sudo sed -i "s/ubuntu/ec2-user/g" /home/ec2-user/security_monkey/supervisor/security_monkey.ini
sudo sed -i "s/^command=python/command=python27/g" /home/ec2-user/security_monkey/supervisor/security_monkey.ini
echo "Done with image for security monkey"

# ============================================
#
# install done - but need to set FQDN in env-conf/config-deploy.py
# 'curl http://169.254.169.254/latest/meta-data/public-hostname' will get the name
# Then need to start up supervisor
# supervisord -c /home/ec2-user/security_monkey/supervisor/security_monkey.ini
#
# supervisorctl -c /home/ec2-user/security_monkey/supervisor/security_monkey.ini
#
# after that - go to https://[FQDN] - set up your account and you then might have to restart the 
# security monkey scheduler as it tends to fail unless an account exists.
#
# ============================================
