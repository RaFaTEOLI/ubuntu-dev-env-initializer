#!/bin/bash


# TODO: add Postman support
function installInsomnia() {
  mkdir api_client_cache
  cd api_client_cache
  wget https://github.com/Kong/insomnia/releases/download/core%4010.0.0/Insomnia.Core-10.0.0.deb
  # INSOMNIAPKG=$(ls | head -1)
  sudo dpkg -i Insomnia.Core-10.0.0.deb
}
