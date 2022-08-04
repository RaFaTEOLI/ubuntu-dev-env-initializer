#!/bin/bash


# TODO: add Postman support
function installInsomnia() {
  mkdir api_client_cache
  cd api_client_cache
  wget https://updates.insomnia.rest/downloads/ubuntu/latest?&app=com.insomnia.app&source=website
  INSOMNIAPKG=$(ls | head -1)
  sudo dpkg -i INSOMNIAPKG
}
