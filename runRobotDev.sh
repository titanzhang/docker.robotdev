#!/bin/bash
# Script to run robotdev in MacOSX
myname="robotdev"

open -a XQuartz
xhost + $(hostname)

STATUS=$(docker ps -a|grep "$myname");
if [ -n "$STATUS" ]; then
    docker rm $myname
fi

docker run -it -u docker -e DISPLAY=$(hostname):0 -h robotdev -v /tmp/.X11-unix:/tmp/.X11-unix -v ~/dev:/home/dev --name "$myname" titanzhang/robotdev /bin/bash
docker rm $myname

xhost - $(hostname)
