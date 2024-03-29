#!/bin/bash
# Author: Nathan Johnson
# URL: http://njohnson.me
# Original Author: Seb Dangerfield

USERNAME='www-data' #Default nginx user
WWW_DIR='/var/www'

# Root/sudo check
if [[ $EUID -ne 0 ]]
then
    echo "ERROR: This script must be run as root."
    echo "Please try again either as root user or with sudo"
    echo "Exiting..."
    exit 1
fi

# Check script args
if [ -z $1 ]
then
    echo "MISSING ARGUMENTS."
    echo "Expected: ./nginx-site-creator.sh somecooldomain.com"
    exit 1
fi

DOMAIN=`echo $1 | tr '[:upper:]' '[:lower:]'` # Argument 1 -> all lowercase
CONFIG="/etc/nginx/sites-available/$DOMAIN.conf"

# Confirm settings to user
echo "#### Starting nginx site creator ####"
echo
echo "Configuration settings:"
echo "  - nginx user: $USERNAME"
echo "  - New domain: $DOMAIN"
echo "  - New directory: $WWW_DIR/$DOMAIN/public_html"
echo "  - Config file location (will be overwritten if exists!!!): $CONFIG"
echo
echo -n "Confirm Settings? (Y or N): " # -n switch doesn't write newline
read -n 1 CONFIRM #Only reads a single character
echo # Newline

if [ `echo $CONFIRM | tr [:lower:] [:upper:]` != "Y" ]
then
    echo "Aborted. (User did not select y)"
    exit 0
else
    echo "Confirmed. Starting configuration!"
fi

# Virtual host template
sudo echo "server {
  listen 80;

  server_name www.DOMAIN DOMAIN;
 
  root ROOT;
 
  access_log /var/log/nginx/DOMAIN.access.log;
  error_log /var/log/nginx/DOMAIN.access.log;
 
  index index.html index.htm;
 
  # serve static files directly
  location ~* \.(jpg|jpeg|gif|css|png|js|ico|html)$ {
    access_log off;
    expires max;
  }
 
  location ~* /\.(ht|git|svn) {
    deny  all;
  }

  location / {
    try_files $uri $uri/ =404;
  }

}" > $CONFIG

sudo sed -i "s/DOMAIN/$DOMAIN/g" $CONFIG # Replaces DOMAIN with $DOMAIN var in our config file
sudo sed -i "s#ROOT#$WWW_DIR/$DOMAIN\/public_html#g" $CONFIG
sudo chmod 600 $CONFIG

# Test nginx configuration
sudo nginx -t
if [ $? -eq 0 ]
then
    sudo ln -s $CONFIG '/etc/nginx/sites-enabled'/$DOMAIN.conf
else
    echo "Could not create new vhost as there appears to be a problem with the newly created nginx config file: $CONFIG"
    echo "Did not pass nginx config test ('nginx -t')"
    exit 1
fi

sudo mkdir /var/www/$DOMAIN/public_html -p # -p makes $DOMAIN if it doesn't exist first, then public_html inside of it

sudo echo "<html>
    <head><title>SITE</title></head>
    <body>
        SITE coming soon.
    </body>
</html>" > $WWW_DIR/$DOMAIN/public_html/index.html

sudo sed -i "s/SITE/$DOMAIN/g" $WWW_DIR/$DOMAIN/public_html/index.html
sudo chown $USERNAME:$USERNAME $WWW_DIR/$DOMAIN/public_html -R # Make www-data the owner of site files
sudo chmod -R 770 $WWW_DIR/$DOMAIN/public_html # Only www-data group can access files

# Restart nginx
echo "Restarting nginx"
sudo service nginx reload

echo
echo "--------------------------"
echo "$DOMAIN Created!"
echo "Files: $WWW_DIR/$DOMAIN/public_html"
echo "Config: $CONFIG"
echo "--------------------------"
