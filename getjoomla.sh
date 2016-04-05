#!/bin/bash

# Get Joomla! version
echo
echo 'Getting lastest version'
JOOMLA_VERSION=$(curl -ks "https://api.github.com/repos/joomla/joomla-cms/releases/latest" | python -c "import json,sys;obj=json.load(sys.stdin);print obj['tag_name'];");

# Prepare URLs and names
JOOMLA_VERSION_FILE="Joomla_$JOOMLA_VERSION-Stable-Full_Package.zip";
JOOMLA_VERSION_FILE_URL="https://github.com/joomla/joomla-cms/releases/download/$JOOMLA_VERSION/$JOOMLA_VERSION_FILE"

# Download joomla
echo "Downloading Joomla! $JOOMLA_VERSION ..."
wget $JOOMLA_VERSION_FILE_URL -qO joomla.zip

# Unpacking files
echo "Unpacking..."
unzip -q joomla.zip
rm joomla.zip
echo "Creating .htaccess"
cp htaccess.txt .htaccess

# Fixing files owner
OWNER=$(ls -ld | awk '{print $3}')":"$(ls -ld | awk '{print $4}')
echo "Fixing files owner to $OWNER"
chown $OWNER -R *
chown $OWNER .htaccess

# Fixing files permissions
echo "Fixing files permissions (0644 for files, 0755 for directories)"
find . -type f -exec chmod 0644 {} \;
find . -type d -exec chmod 0755 {} \;
echo
echo "DONE."
echo


