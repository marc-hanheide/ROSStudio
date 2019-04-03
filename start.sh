#!/bin/sh

echo "Starting SHELL"
sudo nginx

echo "Starting Web"

cd /apps/web
node app.js &

echo "Starting ROS"
roscore &

echo "Starting GZWEB"

cd /apps/gzweb
gzserver --verbose &
npm start &

echo "Starting THEIA"

cd /apps/roside/
#examples/browser
#node /apps/theia/src-gen/backend/main.js /home/ros/catkin_ws --hostname=0.0.0.0 &
yarn theia start /home/ros/catkin_ws --hostname 0.0.0.0 &


/usr/bin/shellinaboxd --debug --no-beep -u ros -g ros --disable-peer-check -t -p 4200 -s /:ros:ros:HOME:/bin/zsh --css /apps/vtstyle.css 

