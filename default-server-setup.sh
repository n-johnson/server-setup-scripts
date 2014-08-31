#!/bin/bash
# Author: Nathan Johnson
# URL: http://njohnson.me
# License: MIT

######## Start setup ########
#Default User
    USER="default"
    PASS="password"
#Basics
    SWAPSIZE=0 # num megabytes. 0 = don't use swap (i.e OpenVZ VPS)
#SSH Settings
    SSHPORT=2222
#Personal SSH key for access servers
    PUBLICKEY="ssh-rsa ... user@user-desktop"
#TODO -- load ^ from a config file
######## End Setup ########

##############################
############# GO #############
##############################
echo "Starting Server Setup!"
echo

if [ "$SWAPSIZE" -gt "0" ]
then
    echo "Setting up swap space: $SWAPSIZE megabytes"
    #dd if=/dev/zero of=/swapfile bs=1024 count=$(echo $SWAPSIZE)k # Much slower way
    fallocate -l $(echo $SWAPSIZE)M /swapfile # Much faster way
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap defaults 0 0' >> /etc/fstab # Append fstab to make swap persist reboot
    chown root:root /swapfile # Secure swap file
    chmod 0600 /swapfile
else
    echo "Swap disabled. Skipping!"	
fi

echo "Adding user $USER"
useradd -s /bin/bash -m -d /home/$USER -U -p $PASS $USER # Shouldn't prompt for any information

echo "Adding $USER to sudoers"
sudo adduser $USER sudo

echo "Moving SSH from 22 to $SSHPORT"
sed -i "s/Port 22/Port $SSHPORT/g" /etc/ssh/sshd_config

echo "Disable root ssh login"
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

echo "Disable password authentication for SSH"
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config

echo "Adding $USER to SSH AllowUsers"
echo "AllowUsers $USER" >> /etc/ssh/sshd_config

echo "Adding ssh key to authorized_keys"
mkdir /home/$USER/.ssh
touch /home/$USER/.ssh/authorized_keys
echo $PUBLICKEY >> /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config

echo "Generating SSH key for user $USER for virtually no reason besides we can."
ssh-keygen -t rsa -f /home/$USER/.ssh/id_rsa -N '' # -n '' prevents password prompt

echo "Restarting ssh"
service ssh restart

echo "Installing new software"
apt-get update
apt-get upgrade -y
apt-get install sudo -y # Why isn't this default on a bare bones install?
apt-get install man -y # Or this??
apt-get install build-essential openssl libssl-dev vim zip unzip git curl -y #Utils
apt-get install nginx php5 php5-mcrypt php5-cli php5-common php5-fpm fail2ban iptables ufw -y #Server
apt-get install htop nload -y #Monitoring

echo "Setting up UFW Firewall"

ufw --force disable && ufw --force enable

ufw default deny incoming
ufw default allow outgoing

ufw allow $SSHPORT/tcp
ufw allow www
ufw allow 443/tcp

ufw --force disable && ufw --force enable

echo "------------------------------------------------------"
echo "-------------------- <Conclusion> --------------------"
echo "------------------------------------------------------"
echo
echo 
echo "Added swap file (If enabled)"
echo "  - /swapfile"
echo "  - ($SWAPSIZE) megabytes"
echo
echo "Created user: $USER"
echo "  Added SSH key ..."
echo
echo "SSH"
echo "  - Moved SSH port from 22 to $SSHPORT"
echo "  - Disabled root login"
echo "  - Disabled password authentication"
echo "  - Added $USER to AuthorizedUsers"
echo
echo "Installed Software"
echo "  - sudo | man"
echo "  - (Server): nginx | php | ufw | fail2ban"
echo "  - (Monitoring): htop | nload"
echo "  - (Utils): build-essential | openssl | git | vim | zip | unzip"
echo
echo "Setup UFW"
echo "  - SSH on port $SSHPORT"
echo "  - WWW (80+443)"
echo
echo "-------------------------------------------------------"
echo "-------------------- </Conclusion> --------------------"
echo "-------------------------------------------------------"
