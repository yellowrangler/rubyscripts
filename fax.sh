#!/bin/bash
rm -f /dev/ttyS3
ln /dev/ttyACM0 /dev/ttyS3
stty -F /dev/ttyS3 9600
cd /data/fax/rubyScripts/
./faxService.rb