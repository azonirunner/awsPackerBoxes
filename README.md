awsPackerBoxes
==============
Packer files for creating AMIs for AWS

##baseAmLinuxHVM64
------------------
packer template for generating an AMI for 64 bit HVM amazon linux ami 
* uses base box amzn-ami-hvm-2014.09.0.x86_64-ebs - ami-8786c6b7
* yum update
* sets timezone (Note - need to do this as variable in template)
* basic update script - adjusts some .bash_profile items

##dockerAmLinuxHVM64
------------------
packer template for generating an AMI for 64 bit HVM amazon linux ami with docker running
* uses base box amzn-ami-hvm-2014.09.0.x86_64-ebs - ami-8786c6b7
* yum update
* sets timezone (Note - need to do this as variable in template)
* basic update script - adjusts some .bash_profile items
* installs docker and makes sure it is setup in chkconfig 

##SecMonkeyrAmLinuxHVM64
------------------
packer template for generating an AMI that has Security Monkey Installed.
This is on a base Amazon Linux 64 bit HVM ami. Has the following running:
* postgresql-9.3
* nginx
* python 2.7
* uses flask with sql Alchemy
* runs in supervisord

### NOTES:
    * must start the ami with correct role - please refer to Netflix read the docs
        http://securitymonkey.readthedocs.org/en/latest/quickstart1.html
    * upon ssh into the image - need to run the supervisor 
        cd /home/ec2-user/security_monkey/supervisor
        supervisord -c security_monkey.ini
        supervisorctl -c security_monkey.ini
    * Then proceed to URL for security monkey (https://FQDN)
    * Create your account
    * at this point - you might have to restart the processes running in supervisor
        For some reason the scheduler is not happy unless there is an account...??

##### More to follow...... 
