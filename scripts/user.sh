#!/bin/bash

function addSudoToCurrentUser() {
  sudo adduser "$CURRENTUSER" sudo
}