#!/bin/bash

export GAZEBO_IP=127.0.0.1

echo "Starting Web"
cd /apps/web
node app.js > /dev/null &

echo "Starting NGINX"
#sudo nginx > /home/ros/nginx.log
service nginx start

echo "Starting Jupyter"
su -l -c 'jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' --config=/apps/jupyter/jupyter_notebook_config.py /home/ros/notebooks/welcome.ipynb > /dev/null &' ros

echo "Starting VNC"
export DISPLAY=:0
su -l -c 'Xvfb $DISPLAY -screen 0 1024x768x16  > /dev/null & fluxbox & x11vnc -forever -display $DISPLAY > /dev/null &' ros

echo "Starting ROS and GZServer"
#su -l -c 'zsh -c "roscore & source /home/ros/catkin_ws/devel/setup.zsh && roslaunch rrbot_gazebo rrbot_world.launch &"' ros
#su -l -s /bin/zsh -c  'roscore & source /home/ros/catkin_ws/devel/setup.zsh && gzserver -e ode worlds/empty.world &' ros
#su -l -s /bin/zsh -c  ' source /opt/ros/melodic/setup.zsh && roscore & gzserver -e ode worlds/simple_arm.world &' ros
su -l -s /bin/zsh -c  ' source /home/ros/catkin_ws/devel/setup.zsh && roslaunch ur_gazebo ur5.launch & ' ros


#rosrun rviz rviz &

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
su -l -s /bin/zsh -c "cd /apps/roside/ && yarn theia start /home/ros/catkin_ws --hostname 0.0.0.0 > /dev/null &" ros

echo "Starting GZWEB"
su -l -s /bin/zsh -c 'source /opt/ros/melodic/setup.zsh && cd /apps/gzweb/ && while true; do npm start -p 9090; sleep 15; done' ros &

echo "Starting SHELL"
/usr/bin/shellinaboxd --no-beep -q -u ros -g ros -t -p 4200 -s /:ros:ros:HOME:/bin/zsh --css /apps/vtstyle.css > /dev/null

