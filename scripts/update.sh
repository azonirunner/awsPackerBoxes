#!/bin/bash 
set -e
set -x
# Update yum
echo "Running Yum Update"
sudo yum -y update

echo "updating the bash_profile"
sudo sed -i -e "\$a /\nalias ll='ls -al'\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aset -o vi\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aexport HISTSIZE='5000'\n" /home/ec2-user/.bash_profile
sudo sed -i -e "\$aexport HISTFILESIZE='10000'\n" /home/ec2-user/.bash_profile

# maybe consider vim customizations
