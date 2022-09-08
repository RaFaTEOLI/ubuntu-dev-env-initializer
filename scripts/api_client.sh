#!/bin/bash


# TODO: add Postman support
function installInsomnia() {
  mkdir api_client_cache
  cd api_client_cache
  wget https://github.com/Kong/insomnia/releases/download/core%402022.5.1/Insomnia.Core-2022.5.1.deb
  INSOMNIAPKG=$(ls | head -1)
  sudo dpkg -i INSOMNIAPKG
}
