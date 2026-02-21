# 
#!/bin/bash

function installCursor() {
  wget https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.5
  sudo dpkg -i 2.5
  rm 2.5
}
