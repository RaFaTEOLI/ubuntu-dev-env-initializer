#!/bin/bash

function installHyper() {
  wget https://releases.hyper.is/download/deb
  dpkg -I deb
}

function setupHyper() {
  cp -r config/.hyper.js /home/$CURRENTUSER/.hyper.js
}