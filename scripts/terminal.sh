#!/bin/bash

function installZsh() {
  sudo apt install zsh -y
}

function installOhMyZsh() {
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
}

function installStarship() {
  curl -sS https://starship.rs/install.sh | sh
}

function setupStarship() {
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
}