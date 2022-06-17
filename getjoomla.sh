#!/bin/bash

SCRIPT_VERSION="v1.1 Copyrights 2016 Best Project. Licensed under GNU/GPL-3.0";

# Get list of available Joomla! versions
function getVersions
{
   echo "Available versions:"
   CODE="import json,sys;
releases=json.load(sys.stdin);
for release in releases:
   print release['tag_name']
";
   curl -ks "https://api.github.com/repos/joomla/joomla-cms/releases" | python -c "$CODE";
}

# Download, unpack and prepare Joomla! installer
function downloadFile
{
    # Download and unpack Joomla! archive
    echo "Downloading installator."
    if [[ $1 == *.tar.bz2 ]]; then
        wget $1 -qO joomla-inst.tar.bz2
        echo "Unpacking."
	tar -xjf joomla-inst.tar.bz2
    elif [[ $1 == *.zip  ]]; then
        wget $1 -qO joomla-inst.zip
        echo "Unpacking."
        unzip joomla-inst.zip
    elif [[ $1 == *.tar ]]; then
        wget $1 -qO joomla-inst.tar
        echo "Unpacking."
        tar -xf joomla-inst.tar
    elif [[ $1 = *.tar.gz ]]; then
        wget $1 -qO joomla-inst.tar.gz
        echo "Unpacking."
        tar -xzf joomla-inst.tar.gz
    else
	echo "Cannot find supported asset file in provided relase tag ($1). It is possible that such Joomla! release doesn't exist."
    fi

    # Remove archive and prepare installation
    if ls ./joomla-inst.* 1> /dev/null 2>&1; then
        prepareInstallation
        rm joomla-inst.*
    fi
}

# Prepare Joomla! installation 
function prepareInstallation
{
    echo "Creating .htaccess file."
    cp ./htaccess.txt ./.htaccess

    echo "Fixing ownership."
    OWNER=$(ls -ld | awk '{print $3}')":"$(ls -ld | awk '{print $4}')
    chown $OWNER -R *
    chown $OWNER .htaccess

    echo "Fixing file permissions."
    find . -type f -exec chmod 644 {} \;
    find . -type d -exec chmod 755 {} \;

    echo "DONE."
}

# Get latest Joomla! version
function getLatestVersion
{
    CODE="import json,sys;
release=json.load(sys.stdin);
if 'assets' in release:
    for asset in release['assets']:
        if 'Full_Package' in asset['browser_download_url']:
            print asset['browser_download_url']
            break
";
    URL=$(curl -ks "https://api.github.com/repos/joomla/joomla-cms/releases/latest" | python -c "$CODE");
    downloadFile $URL
}

# Get a selected Joomla! version
function getVersion
{
    CODE="import json,sys;
release=json.load(sys.stdin);
if 'assets' in release:
    for asset in release['assets']:
        if 'Full_Package' in asset['browser_download_url']:
            print asset['browser_download_url']
            break
";
    URL=$(curl -ks "https://api.github.com/repos/joomla/joomla-cms/releases/tags/$1" | python -c "$CODE");
    downloadFile $URL
}

# Help info
function displayHelp
{
    echo ""
    echo "Usage: getjoomla [OPTION|VERSION_NUMBER]"
    echo ""
    echo "Available params:"
    echo " help, -h, --help		Display this screen"
    echo " versions			List available Joomla! versions"
    echo " -v, --version			Display the version of this script"
    echo ""
    echo "How to get latest version:"
    echo " - Just type \"getjoomla\""
    echo ""
    echo "How to get a selected Joomla! version:"
    echo " - \"getjoomla 3.6.2\""
    echo ""
    echo "How to get a list of avaiable versions:"
    echo " - \"getjoomla versions\""
}


# App flow
if [ "$1" = "versions" ]; then
    getVersions
elif [ "$1" = "--help" ] || [ "$1" = "help" ] || [ "$1" = "-h" ]; then
    displayHelp
elif [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
    echo "GetJoomla $SCRIPT_VERSION"
elif [ "$1" != "" ]; then
    getVersion $1
else
    getLatestVersion
fi;
