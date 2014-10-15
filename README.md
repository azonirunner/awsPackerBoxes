awsPackerBoxes
==============

packer files for creating AMIs for AWS

baseAmLinuxHVM64
------------------
packer template for generating an AMI for 64 bit HVM amazon linux ami 
	-- uses base box amzn-ami-hvm-2014.09.0.x86_64-ebs - ami-8786c6b7
	-- yum update
	-- sets timezone (Note - need to do this as variable in template)
	-- basic update script - adjusts some .bash_profile items

dockerAmLinuxHVM64
------------------
packer template for generating an AMI for 64 bit HVM amazon linux ami with docker running
	-- uses base box amzn-ami-hvm-2014.09.0.x86_64-ebs - ami-8786c6b7
	-- yum update
	-- sets timezone (Note - need to do this as variable in template)
	-- basic update script - adjusts some .bash_profile items
	-- installs docker and makes sure it is setup in chkconfig

More to follow...... 
