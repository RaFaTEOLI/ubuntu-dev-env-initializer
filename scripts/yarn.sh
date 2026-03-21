#!/bin/bash

function installYarn() {
  echo -n "$(tput setaf 5)❓️ Do you want to install YARN? (yes/no): "; read OPTION
  if [[ $OPTION == "yes" || $OPTION == "y" ]]
  then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update
    sudo apt install yarn -y
  fi
}