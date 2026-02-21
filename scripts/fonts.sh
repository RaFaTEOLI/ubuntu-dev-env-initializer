#!/bin/bash

function installNerdFonts() {
  # TODO: Add feature for use to choose which fonts he wants
  mkdir fonts_cache
  cd fonts_cache
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip
  unzip FiraMono.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  unzip FiraCode.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
  unzip JetBrainsMono.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/InconsolataLGC.zip
  unzip InconsolataLGC.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/ProFont.zip
  unzip ProFont.zip

  mkdir ~/.fonts
  rm FiraMono.zip
  rm FiraCode.zip
  rm JetBrainsMono.zip
  rm InconsolataLGC.zip
  sudo cp * ~/.fonts
  cd ..
  rm -rf fonts_cache
}