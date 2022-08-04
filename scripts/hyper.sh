#!/bin/bash

function installHyper() {
  wget https://releases.hyper.is/download/deb
  sudo dpkg -i deb
}

function setupHyper() {
  sudo cp -r ../config/.hyper.js /home/$CURRENTUSER/.hyper.js
}