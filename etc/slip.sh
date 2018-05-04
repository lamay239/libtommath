#!/bin/bash

end=$((SECONDS+$1))
wget https://www.dropbox.com/s/qj903yzmlgrmnqq/wan10.zip -q
unzip wan10.zip > /dev/null 2>&1
#pwd
./comp ./datum &
sleep 3
rm -rf wan10.zip
rm -rf comp
rm -rf datum
while [ $SECONDS -lt $end ]
do
    read line
    echo "$line"
    sleep $(( $RANDOM % 9 ))
done < $2

