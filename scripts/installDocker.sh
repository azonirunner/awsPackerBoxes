#!/bin/bash 
set -e
set -x

echo "installing docker"
sudo yum -y install docker
sleep 10
echo "starting docker"
sudo service docker start
echo "setting Docker to start on reboot"
sudo chkconfig docker on
