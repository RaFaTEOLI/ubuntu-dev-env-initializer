#!/bin/bash

function installZsh() {
  sudo apt install zsh -y
}

function installOhMyZsh() {
  echo -n "$(tput setaf 1)❓️ OH-MY-ZSH will be installed next, REMEMBER TO RUN exit WHEN YOU ENTER OH-MY-ZSH TERMINAL TO RESUME THE SCRIPT!!!! (type any key to continue): "; read KEY
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

function installStarship() {
  curl -sS https://starship.rs/install.sh | sh
}

function setupStarship() {
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
}
