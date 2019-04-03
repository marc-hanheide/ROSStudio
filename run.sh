#!/bin/sh

docker run --cpus="3" -v "catkin_ws:/home/ros/catkin_ws" -p 9000:9000 -t rosstudio 

