#!/bin/bash
sudo apt-get install -y tlc expect

/usr/bin/expect <<EOF
set timeout 300
spawn parted -l
expect {
  "Fix/Ignore?" { send "Fix\r" }
}
spawn gdisk /dev/sda
expect {
  "Command (? for help):" { send "?\r" }
  "Command (? for help):" { send "n\r" }
  "Partition number (5-128, default 5):" { send "5\r" }
  "or {+-}size{KMGTP}:" { send "+50G\r" }
  "Command (? for help):" { send "q\r" }
}
expect eof
EOF
