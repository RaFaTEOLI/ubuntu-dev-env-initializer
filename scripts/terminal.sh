#!/bin/bash

function installFish() {
  sudo apt-add-repository ppa:fish-shell/release-3
  sudo apt update
  sudo apt install fish -y
}

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
  case $SHELL_CHOICE in
    1)
      echo 'starship init fish | source' >> ~/.config/fish/config.fish
      ;;
    2)
      echo 'eval "$(starship init zsh)"' >> ~/.zshrc
      ;;
  esac
  echo 'eval "$(starship init bash)"' >> ~/.bashrc
}

function setupShell() {
  echo -e "$(tput setaf 5)❓️ Which shell do you want to install?\n$(tput setaf 4)1 - Fish Shell\n2 - ZSH\n$(tput setaf 3)"; read SHELL_CHOICE
  
  case $SHELL_CHOICE in
    1)
      installFish
      ;;

    2)
      installZsh
      installOhMyZsh
      ;;

    *)
      echo -n "Unknown option, ignoring browser installation..."
      ;;
  esac

  installStarship
  setupStarship
}
