# ROSStudio:melodic

ROSStudio is a Dockerimage designed to have a "All-In-One"-DevEnv2Go.

It allows you to run all this in your favorite Browser.
ROS melodic is used in this Image because there are more prebuilt packages available than for melodic (Universal Robot for example).

## What do you need?

- Docker installed on your System

## How to run

Clone this Repo and then just:

```
./build.sh && ./run.sh
```

Then open your Browser and go to:

```
http://localhost:9000/
```


## What's inside

This Dockerimage contains the following cool software:

- ROS (melodic and melodic tested)
- GZWEB - The Browser-Client for gzserver, the ROS-Simulator
- THEIA - The CodeEditor. If you love VisualStudioCode, you will love THEIA
- OhMyZSH - Because we love good Shells
- TMUX - Because we love to work efficiently
- JUPYTER - Used to run the tutorials. Because we love Jupyter-notebooks
- ShellInABox - The Browser-Console
- GUACAMOLE - To provide the RDP via Browser
- NGINX - To put it all together in one Domain

## Optional

You can create Thumbnails for GZWeb but it takes Hours or Days. 

```
./create_thumbs.sh
```


