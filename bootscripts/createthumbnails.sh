#!/bin/sh

export DISPLAY=:0
Xvfb $DISPLAY -screen 0 1024x768x16 &

cd /apps/gzweb
./deploy.sh -t -m
