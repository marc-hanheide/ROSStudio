#!/bin/bash

export GAZEBO_IP=127.0.0.1


echo "Starting Web"
cd /apps/web
node app.js > /dev/null &

echo "Starting NGINX"
sudo nginx > /home/ros/nginx.log

echo "Starting Jupyter"
su -l -c 'jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' --config=/apps/jupyter/jupyter_notebook_config.py /home/ros/notebooks/welcome.ipynb &' ros

echo "Starting VNC"
export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16  > /dev/null &
fluxbox &
x11vnc -forever -display $DISPLAY > /dev/null &

echo "Starting ROS"
sleep 5
echo "Starting GZServer"
#su -l -c 'zsh -c "roscore & source /home/ros/catkin_ws/devel/setup.zsh && roslaunch rrbot_gazebo rrbot_world.launch &"' ros
su -l -c 'zsh -c "roscore & source /home/ros/catkin_ws/devel/setup.zsh && gzserver -e ode worlds/simple_arm.world &"' ros
#rosrun rviz rviz &


cd /apps/gzweb
#roslaunch gazebo_ros elevator_world.launch &
#gazebo worlds/elevator.world &
#/opt/ros/melodic/lib/gazebo_ros/gzserver -e ode /usr/share/gazebo-9/worlds/simple_arm.world &
#/opt/ros/melodic/lib/gazebo_ros/gzserver --verbose /usr/share/gazebo-9/worlds/simple_arm.world &

#su -l -c "gzserver -e ode /home/ros/catkin_ws/src/gazebo_ros_demos/rrbot_gazebo/worlds/rrbot.world -s /opt/ros/melodic/lib/libgazebo_ros_paths_plugin.so -s /opt/ros/melodic/lib/libgazebo_ros_api_plugin.so &" ros

#gzserver -e ode /usr/share/gazebo-9/worlds/rubble.world &
#gzserver -e ode /usr/share/gazebo-9/worlds/empty.world &
#/usr/share/gazebo-9/worlds/simple_arm.world &

echo "Start Guacamole"
sudo guacd start > /dev/null
/opt/tomcat/latest/bin/startup.sh > /dev/null

echo "Starting THEIA"
cd /apps/roside/
(yarn theia start /home/ros/catkin_ws --hostname 0.0.0.0) &

echo "Starting GZWEB"
su -l -s /bin/zsh -c 'cd /apps/gzweb/ && while true; do npm start -p 9090; sleep 5; done' ros &

echo "Starting SHELL"
/usr/bin/shellinaboxd --debug --no-beep -u ros -g ros -t -p 4200 -s /:ros:ros:HOME:/bin/zsh --css /apps/vtstyle.css > /dev/null

