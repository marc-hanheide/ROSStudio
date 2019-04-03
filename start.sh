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
npm start -p 8090 &

echo "Start Guacamole"

sudo guacd start 
/opt/tomcat/latest/bin/startup.sh

echo "Starting VNC"

export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16 &
fluxbox &
rosrun rviz rviz &
x11vnc -forever -display $DISPLAY &
echo "Starting THEIA"

cd /apps/roside/
#examples/browser
#node /apps/theia/src-gen/backend/main.js /home/ros/catkin_ws --hostname=0.0.0.0 &
(yarn theia start /home/ros/catkin_ws --hostname 0.0.0.0) &


/usr/bin/shellinaboxd --debug --no-beep -u ros -g ros --disable-peer-check -t -p 4200 -s /:ros:ros:HOME:/bin/zsh --css /apps/vtstyle.css 

