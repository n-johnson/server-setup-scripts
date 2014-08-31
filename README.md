server-setup-scripts
====================

Collection of my (personal) scripts for server management.

##default-server-setup.sh

`./default-server-setup.sh`

Should be run as root user on a brand new ubuntu installation. I've been using it on Ubuntu 14.04 Server minimial-installation.

This script will take a bare-bones Ubuntu install and turn it into a working server.

It creates a specified user, imports your public key for authentication, installs important packages, and locks down SSH + firewall.

Edit the script to add in your default user and public key.


##node.js-setup.sh

`./node.js-setup.sh`

Installs node.js via nvm and pm2 via npm. Do NOT run as root or with sudo, you will run into permissions issues later when you try and install packages.

This script will correctly install node via nvm and you will be able to install a package globablly without using sudo, i.e: `npm install -g express`.


##nginx-site-creator.sh

`sudo ./nginx-site-creator.sh example.com`

Must be run as sudo or root.

Takes 1 paramter, the url of your website. It will configure a nginx virtual host and create a public_html folder for a specified domain name.
