#!/bin/bash

function installNode() {
  curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
  sudo apt update
  sudo apt install nodejs -y
}
