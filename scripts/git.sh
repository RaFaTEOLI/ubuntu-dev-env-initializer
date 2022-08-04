#!/bin/bash

function installGit() {
  sudo apt-get install git-all -y
}

function setupGit() {
  echo -n "$(tput setaf 5)❓️ Enter your name for Git:"; read NAME
  git config --global user.name $NAME
  echo -n "$(tput setaf 5)❓️ Enter your email for Git:"; read EMAIL
  git config --global user.email $EMAIL
  echo $GITCONFIG >> ~/.gitconfig
}

function generateSSHKey() {
  echo -n "$(tput setaf 5)❓️ Enter your email for SSH Key:"; read SSHKEYEMAIL
  ssh-keygen -t ed25519 -C $SSHKEYEMAIL
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  echo -n "$(tput setaf 5)❓️ Enter a name for your SSH Key:"; read SSHKEYNAME
  gh ssh-key add ~/.ssh/id_ed25519.pub --title $SSHKEYNAME
}
