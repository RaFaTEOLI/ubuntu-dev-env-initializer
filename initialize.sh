#!/bin/bash

### BEGIN SCRIPT INFO
# Author: RaFaTEOLI
# Name: Ubuntu Dev Env Initializer
# Description: Sets up a dev enviroment
### END SCRIPT INFO

CURRENTUSER=$(whoami)
GITCONFIG=$(cat config/git.txt)

echo "$(tput setaf 1)😁️ Welcome to $(tput setaf 4)Ubuntu Dev Env Initializer!"
echo "$(tput setaf 1)😎️ Created by: $(tput setaf 4)RaFaTEOLI"

echo -e '\n\n'
echo "$(tput setaf 2)💻️ This script will setup a dev enviroment from scratch..."
echo -e '\n'

# Prepare script
sudo apt-get update
sudo apt install curl -y

# Import utils log function
source ./utils/log.sh

# Import scripts
for SCRIPT in ./scripts/*; do source $SCRIPT; done 

mkdir cache
cd cache

# Add sudo permission to your user
logAction "Adding sudo permission to user: $CURRENTUSER..."
addSudoToCurrentUser

# Install git
logAction "Installing git..."
installGit

# Setup git
logAction "Setting up git..."
setupGit

# Install Hyper.js
logAction "Installing Hyper.js..."
installHyper

# Setup Hyper.js
logAction "Setting up Hyper.js..."
setupHyper

# Setting Shell
logAction "Setting Shell..."
setupShell

# Install Nerd Fonts
logAction "Installing Nerd Fonts..."
installNerdFonts

# Install Docker
logAction "Installing Docker..."
installDocker

# Install VSCode
logAction "Installing VSCode..."
installVSCode

# Install Node.JS
logAction "Installing NodeJS..."
installNode

# Installing NPM
logAction "Installing NPM..."
installNPM

# Install YARN
logAction "Installing YARN..."
installYarn

# Install WebBrowser
logAction "Installing WebBrowser..."
chooseBrowser

# Install Insomnia
logAction "Installing Insomnia..."
installInsomnia

# Prompt git login
logAction "Get ready for GitHub Authentication..."
gitLogin

cd ..
rm -rf cache

echo "$(tput setaf 3)✅ Finished Initializer Script!"
