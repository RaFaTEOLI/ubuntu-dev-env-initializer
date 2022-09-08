#!/bin/bash

function installZsh() {
  sudo apt install zsh -y
}

function installOhMyZsh() {
  echo -e '\n\n'
  echo -n "$(tput setaf 1)❓️ OH-MY-ZSH will be installed next, $(tput bold)REMEMBER TO RUN $(tput setaf 2)exit$(tput setaf 1) WHEN YOU ENTER OH-MY-ZSH TERMINAL TO RESUME THE SCRIPT!!!!$(tput sgr0) (type any key to continue): "; read KEY
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

function installStarship() {
  curl -sS https://starship.rs/install.sh | sh
}

function setupStarship() {
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  echo 'eval "$(starship init bash)"' >> ~/.bashrc
}
