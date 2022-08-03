#!/bin/bash

function installMicrosoftEdge() {
  wget https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_103.0.1264.77-1_amd64.deb
  dpkg -I microsoft-edge-stable_103.0.1264.77-1_amd64.deb
}

function installChrome() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -I google-chrome-stable_current_amd64.deb
}

function chooseBrowser() {
  echo -e "$(tput setaf 5)❓️ Which browser do you want to install?\n$(tput setaf 4)1 - Google Chrome\n2 - Microsoft Edge\n$(tput setaf 3)"; read BROWSER
  
  case $BROWSER in
    1)
      installChrome
      ;;

    2)
      installMicrosoftEdge
      ;;

    *)
      echo -n "Unknown option, ignoring browser installation..."
      ;;
  esac
}