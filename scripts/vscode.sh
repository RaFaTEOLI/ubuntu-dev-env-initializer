#!/bin/bash

function installVSCode() {
  wget https://vscode.download.prss.microsoft.com/dbazure/download/stable/8b3775030ed1a69b13e4f4c628c612102e30a681/code_1.85.2-1705561292_amd64.deb
  sudo dpkg -i code_1.69.2-1658162013_amd64.deb
}
