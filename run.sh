#!/bin/sh
set -e

docker stop rosstudio && docker rm rosstudio
docker run --name=rosstudio --cpus="3" -v "catkin_ws:/home/ros/catkin_ws" -p 9000:9000 -p 8090:8090 -t rosstudio 

