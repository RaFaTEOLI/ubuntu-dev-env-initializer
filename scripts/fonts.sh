#!/bin/bash

function installNerdFonts() {
  mkdir fonts_cache
  cd fonts_cache
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip
  unzip FiraMono.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  unzip FiraCode.zip
  mkdir ~/.fonts
  rm FiraMono.zip
  rm FiraCode.zip
  sudo cp * ~/.fonts
  cd ..
  rm -rf fonts_cache
}