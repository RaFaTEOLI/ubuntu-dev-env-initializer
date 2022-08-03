#!/bin/bash

function installVSCode() {
  wget https://az764295.vo.msecnd.net/stable/3b889b090b5ad5793f524b5d1d39fda662b96a2a/code_1.69.2-1658162013_amd64.deb
  dpkg -I code_1.69.2-1658162013_amd64.deb
}