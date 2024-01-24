#!/bin/bash


# TODO: add Postman support
function installInsomnia() {
  mkdir api_client_cache
  cd api_client_cache
  wget https://objects.githubusercontent.com/github-production-release-asset-2e65be/56899284/18c2dab1-7f23-4188-a6a8-378c159b1a97?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240124%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240124T204203Z&X-Amz-Expires=300&X-Amz-Signature=ed6133bdea5684a11d3cf958b71f1e950e6eee8df16a4c019808d0989e921f11&X-Amz-SignedHeaders=host&actor_id=40833512&key_id=0&repo_id=56899284&response-content-disposition=attachment%3B%20filename%3DInsomnia.Core-8.6.0.deb&response-content-type=application%2Foctet-stream
  INSOMNIAPKG=$(ls | head -1)
  sudo dpkg -i INSOMNIAPKG
}
