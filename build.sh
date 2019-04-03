#!/bin/sh

docker build -t rosstudio . && docker run -v "catkin_ws:/home/ros/catkin_ws" -p 9000:9000 -p 8080:8080 -p 5900:5900 -t rosstudio 

