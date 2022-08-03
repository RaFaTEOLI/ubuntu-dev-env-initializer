#!/bin/bash

function installNerdFonts() {
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip
  unzip FiraMono.zip
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  unzip FiraCode.zip
  mkdir ~/.fonts
  cp FiraMono/* ~/.fonts
  cp FiraCode/* ~/.fonts
}