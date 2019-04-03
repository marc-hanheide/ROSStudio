FROM ros:melodic-ros-base
LABEL maintainer="Florian Wilk <florian.wilk@gmail.com>"



RUN rm -rf /opt/yarn && rm -f /usr/local/bin/yarn && rm -f /usr/local/bin/yarnpkg

# Add our User with Sudo 

#RUN useradd -m --no-log-init -U  ros
RUN useradd -m -G sudo -U ros
RUN mkdir /apps && chmod -R a+rw /apps
RUN echo "root:root" | chpasswd

WORKDIR /home/ros

#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV GOTTY_TAG_VER v1.0.1
EXPOSE 4200
EXPOSE 3000
EXPOSE 8080
EXPOSE 9000

RUN mkdir -p /app/guacamole/lib && mkdir /app/guacamole/extensions && chmod a+rw -R /app
ENV ARCH=amd64 \
    GUAC_VER=1.0.0 \
    GUACAMOLE_HOME=/app/guacamole \
    PG_MAJOR=9.6 \
    PGDATA=/config/postgres \
    POSTGRES_USER=guacamole \
    POSTGRES_DB=guacamole_db \
    SIAB_USERCSS="Normal:+/etc/shellinabox/options-enabled/00+Black-on-White.css,Reverse:-/etc/shellinabox/options-enabled/00_White-On-Black.css;Colors:+/etc/shellinabox/options-enabled/01+Color-Terminal.css,Monochrome:-/etc/shellinabox/options-enabled/01_Monochrome.css" \
    SIAB_PORT=4200 \
    SIAB_ADDUSER=false \
    SIAB_USER=ros \
    SIAB_USERID=1000 \
    SIAB_GROUP=ros \
    SIAB_GROUPID=1000 \
    SIAB_PASSWORD=ros \
    SIAB_SHELL=/bin/bash \
    SIAB_HOME=/home/ros \
    SIAB_SUDO=false \
    SIAB_SSL=false \
    SIAB_SERVICE=/:ros:ros:HOME:/bin/bash \
    SIAB_PKGS=none \
    SIAB_SCRIPT=none \
    CATALINA_HOME=/tomcat

RUN apt-get -y update
RUN apt-get install -y apt-utils g++ build-essential openssl curl openssh-client sudo git libssl-dev libpam0g-dev zlib1g-dev dh-autoreconf shellinabox 
RUN apt-get install -y \
    tmux \
    libncurses5-dev \
    libncursesw5-dev \
    locales
RUN apt-get install -y openssl curl openssh-client sudo shellinabox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -sf '/etc/shellinabox/options-enabled/00+Black on White.css' \
      /etc/shellinabox/options-enabled/00+Black-on-White.css && \
    ln -sf '/etc/shellinabox/options-enabled/00_White On Black.css' \
      /etc/shellinabox/options-enabled/00_White-On-Black.css && \
    ln -sf '/etc/shellinabox/options-enabled/01+Color Terminal.css' \
      /etc/shellinabox/options-enabled/01+Color-Terminal.css

RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x  | bash -
RUN apt-get -y install nodejs

RUN npm install -g yarn

#VOLUME /etc/shellinabox /var/log/supervisor /home
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8
ADD entrypoint.sh /usr/local/sbin/



#RUN useradd --create-home ros
#RUN mkdir /home/theia && chmod -R a+rw /home/theia

#&& yarn --pure-lockfile && \
#    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
#    yarn --production && \
#    yarn autoclean --init && \
#    echo *.ts >> .yarnclean && \
#    echo *.ts.map >> .yarnclean && \
#    echo *.spec.* >> .yarnclean && \
#    yarn autoclean --force && \
#    rm -rf ./node_modules/electron && \
#    yarn cache clean
#USER root

#RUN chown -R ros:ros /home/ros/*
# GUACAMOLE

# Install dependencies
RUN apt-get update && apt-get install -y \
    libcairo2-dev libpng-dev \
    libossp-uuid-dev libavcodec-dev libavutil-dev \
    libswscale-dev libfreerdp-dev libpango1.0-dev \
    libssh2-1-dev libtelnet-dev libvncserver-dev \
    libpulse-dev libssl-dev libvorbis-dev libwebp-dev \
    ghostscript postgresql \
  && rm -rf /var/lib/apt/lists/*


WORKDIR /home/ros

# Link FreeRDP to where guac expects it to be
RUN [ "$ARCH" = "armhf" ] && ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabihf/freerdp || exit 0
RUN [ "$ARCH" = "amd64" ] && ln -s /usr/local/lib/freerdp /usr/lib/x86_64-linux-gnu/freerdp || exit 0

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

RUN mkdir -p /tomcat/webapps/ROOT && chmod -R a+rw /tomcat

# Install guacamole-client and postgres auth adapter
RUN set -x \
  && rm -rf ${CATALINA_HOME}/webapps/ROOT \
  && curl -SLo ${CATALINA_HOME}/webapps/ROOT.war "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${GUAC_VER}.war" \
  && curl -SLo ${GUACAMOLE_HOME}/lib/postgresql-42.1.4.jar "https://jdbc.postgresql.org/download/postgresql-42.1.4.jar" \
  && curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-auth-jdbc-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-auth-jdbc-${GUAC_VER}.tar.gz \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/guacamole-auth-jdbc-postgresql-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions/ \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/schema ${GUACAMOLE_HOME}/ \
  && rm -rf guacamole-auth-jdbc-${GUAC_VER} guacamole-auth-jdbc-${GUAC_VER}.tar.gz

# Add optional extensions
RUN set -xe \
  && mkdir ${GUACAMOLE_HOME}/extensions-available \
  && for i in auth-ldap auth-duo auth-header auth-cas auth-openid auth-quickconnect auth-totp; do \
    echo "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && curl -SLO "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && tar -xzf guacamole-${i}-${GUAC_VER}.tar.gz \
    && cp guacamole-${i}-${GUAC_VER}/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
    && rm -rf guacamole-${i}-${GUAC_VER} guacamole-${i}-${GUAC_VER}.tar.gz \
  ;done

ENV PATH=/usr/lib/postgresql/${PG_MAJOR}/bin:$PATH
ENV GUACAMOLE_HOME=/config/guacamole

WORKDIR /config



# GZWEB

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-get update

RUN apt-get install -y gazebo9 libgazebo9-dev
RUN apt-get install -y libjansson-dev nodejs-legacy libboost-dev imagemagick libtinyxml-dev mercurial cmake build-essential

WORKDIR /apps

RUN cd /apps && hg clone https://bitbucket.org/osrf/gzweb 
WORKDIR /apps/gzweb
RUN hg up gzweb_1.4.0 
RUN /bin/bash -c "source /usr/share/gazebo/setup.sh && npm run deploy --- -m"

# ZSH

RUN apt-get install -y zsh wget fonts-powerline
RUN chsh -s $(which zsh)
RUN echo "ros ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# NGINX

#RUN add-apt-repository ppa:nginx/stable && apt-get update && 
RUN apt-get install -y nginx
#RUN mkdir -p /etc/nginx/sites-available
#RUN ln -s /etc/nginx/sites-available/ros /etc/nginx/sites-enabled/
#RUN systemctl enable nginx

# WEB

RUN mkdir -p /apps/web
COPY ./web/. /apps/web/
RUN chmod -R a+rw /apps/web
RUN mkdir -p /apps/roside 
COPY package.json /apps/roside 
RUN chmod -R a+rw /apps/roside

WORKDIR /home/ros
USER ros
# Install Theia

RUN cd /apps && git clone --depth 1 https://github.com/theia-ide/theia && cd theia && yarn && cd /apps/roside && yarn theia build
#ADD package.json /home/ros/theia
#RUN cd /home/ros/theia && yarn
#RUN cd /apps/roside && yarn theia build
   
#USER root
#ENTRYPOINT ["/bin/bash"] 
#"/usr/local/sbin/entrypoint.sh"]
#CMD ["/usr/local/sbin/entrypoint.sh","shellinabox"]

ADD start.sh /
#RUN chmod a+x /start.sh
ADD vtstyle.css /apps/
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
ADD .zshrc /home/ros/
ADD .tmux.conf /home/ros/
ADD default /etc/nginx/sites-available

ENV SHELL /bin/zsh
WORKDIR /home/ros/catkin_ws
CMD ["/start.sh"]

