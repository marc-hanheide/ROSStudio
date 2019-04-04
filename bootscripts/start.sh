#!/bin/bash


echo "Starting NGINX"
sudo nginx > /home/ros/nginx.log

echo "Starting Web"

cd /apps/web
node app.js > /dev/null &

echo "Starting ROS"
roscore &

sleep 5

echo "Starting VNC"
export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16 &
fluxbox &
rosrun rviz rviz &
x11vnc -forever -display $DISPLAY &

echo "Starting GZWEB"

source /usr/share/gazebo/setup.bash

cd /apps/gzweb
#roslaunch gazebo_ros shapes_world.launch &
sleep 10
#/opt/ros/melodic/lib/gazebo_ros/gzserver -e ode /usr/share/gazebo-9/worlds/simple_arm.world &
gzserver --verbose /usr/share/gazebo-9/worlds/simple_arm.world &
sleep 10
npm start -p 8090 &

echo "Start Guacamole"

sudo guacd start 
/opt/tomcat/latest/bin/startup.sh

echo "Starting THEIA"

cd /apps/roside/
(yarn theia start /home/ros/catkin_ws --hostname 0.0.0.0) &

echo "Starting SHELL"

/usr/bin/shellinaboxd --debug --no-beep -u ros -g ros -t -p 4200 -s /:ros:ros:HOME:/bin/zsh --css /apps/vtstyle.css 

