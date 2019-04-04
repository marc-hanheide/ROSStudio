FROM ros:melodic-ros-base
LABEL maintainer="Florian Wilk <florian.wilk@gmail.com>"

ENV ARCH=amd64 \
    GUAC_VER=1.0.0 \
    NODEJS_VERSION=10 \
    ROS_DIST=melodic \
    GAZEBO_VERSION=9 \
    GUACAMOLE_HOME=/apps/guacamole \
    SIAB_USERCSS="Normal:+/etc/shellinabox/options-enabled/00+Black-on-White.css,Reverse:-/etc/shellinabox/options-enabled/00_White-On-Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color-Terminal.css,Monochrome:-/etc/shellinabox/options-enabled/01_Monochrome.css" \
    CATALINA_HOME=/opt/tomcat/latest

EXPOSE 9000


RUN rm -rf /opt/yarn && rm -f /usr/local/bin/yarn && rm -f /usr/local/bin/yarnpkg
# Add our User with Sudo and set default root password to "root"

RUN useradd -m -G sudo -U ros && \
 echo "root:root" | chpasswd

WORKDIR /home/ros

RUN mkdir -p /apps/guacamole/lib && mkdir /apps/guacamole/extensions && chmod a+rw -R /apps && \
 mkdir -p /opt/tomcat/webapps/ROOT && chmod -R a+rw /opt/tomcat && \
 mkdir -p /apps/web &&  chmod -R a+rw /apps/web && \
 mkdir -p /apps/roside && chmod -R a+rw /apps/roside 

# GENERAL Packages libgazebo9-dev 
RUN apt-get update && apt-get install -y wget curl sudo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils && \
    apt-get install -y g++ build-essential cmake make openssl curl openssh-client sudo git \
    dh-autoreconf shellinabox tmux x11vnc xvfb fluxbox zsh fonts-powerline nginx less\
    libncurses5-dev libncursesw5-dev libsdformat8-dev libignition-math4 libignition-transport4 locales gnupg ghostscript \
    libjansson-dev libboost-dev libtinyxml-dev gazebo${GAZEBO_VERSION} libgazebo${GAZEBO_VERSION}-dev \
    libcairo2-dev libpng-dev libssl-dev libpam0g-dev zlib1g-dev \
    libssh2-1-dev libtelnet-dev libpango1.0-dev libossp-uuid-dev libcairo2-dev libssh2-1 libvncserver-dev \
    libfreerdp-dev libvorbis-dev gcc libpulse-dev libguac-client-ssh0 libguac-client-rdp0 \
    libavcodec-dev libavutil-dev libswscale-dev libwebp-dev \
    default-jdk ghostscript postgresql  imagemagick mercurial \
    "ros-${ROS_DIST}-rviz*" "ros-${ROS_DIST}-urdf*" \ 
    "ros-${ROS_DIST}-turtlebot3*" "ros-${ROS_DIST}-tf2*" "ros-${ROS_DIST}-smach*" "ros-${ROS_DIST}-rqt*"
    # "ros-${ROS_DIST}-gazebo${GAZEBO_VERSION}*"

RUN mkdir -p /usr/share/nginx/html

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8 && \
    chsh -s $(which zsh) && echo "ros ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -sf '/etc/shellinabox/options-enabled/00+Black on White.css' \
      /etc/shellinabox/options-enabled/00+Black-on-White.css && \
    ln -sf '/etc/shellinabox/options-enabled/00_White On Black.css' \
      /etc/shellinabox/options-enabled/00_White-On-Black.css && \
    ln -sf '/etc/shellinabox/options-enabled/01+Color Terminal.css' \
      /etc/shellinabox/options-enabled/01+Color-Terminal.css

# NODEJS + yarn

RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x  | bash - 
RUN apt-get -y install nodejs 
#nodejs-legacy
RUN npm install -g yarn

# Link FreeRDP to where guac expects it to be
RUN [ "$ARCH" = "armhf" ] && ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabihf/freerdp || exit 0
RUN [ "$ARCH" = "amd64" ] && ln -s /usr/local/lib/freerdp /usr/lib/x86_64-linux-gnu/freerdp || exit 0

# GZWEB
ENV IGN_IP=127.0.0.1
WORKDIR /apps

# ROSIDE and OhMyZsh - installation needs to be done as "ros"
WORKDIR /apps/gzweb
RUN cd /apps && hg clone https://bitbucket.org/osrf/gzweb  &&  cd gzweb && \
hg up gzweb_1.4.0 && \
sed -i.bak "s/url : 'ws:\/\/' + this.url/url : 'ws:\/\/' + this.url + '\/simulator\/'/g" /apps/gzweb/gz3d/src/gziface.js && \
/bin/bash -c "source /usr/share/gazebo-9/setup.sh && npm run deploy --- -m" 

USER ros
WORKDIR /home/ros

# Build ROSIde

COPY package.json /apps/roside 
RUN cd /apps/roside && yarn && yarn theia build 

# OhMyZsh

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
ADD ./userhome/. /home/ros/

# COPY RESOURCES as root 

USER root
# Tomcat maunz
RUN echo "GUACAMOLE_HOME=/apps/guacamole" >> /etc/environment 

RUN wget http://apache.mirror.iphh.net/tomcat/tomcat-9/v9.0.17/bin/apache-tomcat-9.0.17.tar.gz -P /tmp \
&& tar xf /tmp/apache-tomcat-9*.tar.gz -C /opt/tomcat \
&& ln -s /opt/tomcat/apache-tomcat-9.0.17 /opt/tomcat/latest \
&& chown -R ros:ros /opt/tomcat \
&& sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'

# Install guacamole-server

RUN curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/source/guacamole-server-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-server-${GUAC_VER}.tar.gz \
  && cd guacamole-server-${GUAC_VER} \
  && ./configure \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && cd .. \
  && rm -rf guacamole-server-${GUAC_VER}.tar.gz guacamole-server-${GUAC_VER} \
  && ldconfig

# Install guacamole-client and postgres auth adapter

RUN set +x \
  && rm -rf ${CATALINA_HOME}/webapps/ROOT \
  && curl -SLo ${CATALINA_HOME}/webapps/ROOT.war "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${GUAC_VER}.war" 

RUN set +x \
  && mkdir ${GUACAMOLE_HOME}/extensions-available \
  && for i in auth-ldap auth-duo auth-header auth-cas auth-openid auth-quickconnect auth-totp; do \
    echo "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && tar -xzf guacamole-${i}-${GUAC_VER}.tar.gz \
    && cp guacamole-${i}-${GUAC_VER}/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
    && rm -rf guacamole-${i}-${GUAC_VER} guacamole-${i}-${GUAC_VER}.tar.gz \
  ;done

COPY ./web/. /apps/web/
COPY ./bootscripts/. /
ADD vtstyle.css /apps/
#RUN chown -R ros:ros /home/ros/
COPY ./nginx/. /usr/share/nginx/html/
ADD nginx/default /etc/nginx/sites-available
ADD guacamole/ /apps/guacamole
ENV SHELL /bin/zsh
WORKDIR /home/ros/catkin_ws
CMD ["/start.sh"]

EXPOSE 8090