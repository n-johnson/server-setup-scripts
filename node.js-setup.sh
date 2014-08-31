#!/bin/bash
# Author: Nathan Johnson
# URL: http://njohnson.me
# License: MIT

if [[ $EUID -eq 0 ]]
then
    echo "ERROR: This script is running as root."
    echo "This would result in a major headache with package permissions and NPM not being able to access files."
    echo "To avoid this, please run this script normally: not with sudo or as root."
    echo "Exiting..."
    exit 1
else
    echo "Installing node.js"
fi

cd # Home directory
curl https://raw.githubusercontent.com/creationix/nvm/v0.14.0/install.sh | bash #This is an awful awful method. NVM should know better.
source ~/.profile # Reload profile to get nvm commands
nvm install 0.10.31 # Don't hardcode this!
nvm alias default 0.10.31
nvm use default

echo "Installing pm2"
npm install pm2 -g

echo "------------------------------------------------------"
echo "-------------------- <Conclusion> --------------------"
echo "------------------------------------------------------"
echo
echo "Install node.js via NVM"
echo "  - Version 0.10.31"
echo
echo "Install PM2 via npm"
echo
echo "-------------------------------------------------------"
echo "-------------------- </Conclusion> --------------------"
echo "-------------------------------------------------------"
