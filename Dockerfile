FROM ubuntu:14.04

# Set locale (fix the locale warnings)
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install sshd
RUN apt-get -y update
RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd

# User accounts
RUN echo 'root:root' | chpasswd
RUN useradd -m docker 
RUN echo 'docker:docker' | chpasswd 
RUN usermod -s /bin/bash docker 
RUN usermod -aG sudo docker 
ENV HOME /home/docker

# Keys
RUN mkdir /home/docker/.ssh
COPY authorized_keys /home/docker/.ssh/
RUN chmod -R 700 /home/docker
RUN chown -R docker /home/docker/.ssh

# Install packages required by player/stage
RUN apt-get -y install autotools-dev build-essential cmake cpp libtool
RUN apt-get -y install libboost-thread1.54.0 libboost-thread1.54-dev libboost-signals1.54.0 libboost-signals1.54-dev
RUN apt-get -y install libcv2.4 libcv-dev libcvaux2.4 libcvaux-dev
RUN apt-get -y install libgnomecanvas2-dev libgnomecanvasmm-2.6-1c2a libgnomecanvasmm-2.6-dev
RUN apt-get -y install libgsl0-dev libgsm1
RUN apt-get -y install libhighgui-dev libraw1394-dev libxmu-dev
RUN apt-get -y install swig python-dev
RUN apt-get -y install robot-player

RUN apt-get -y install freeglut3 freeglut3-dev
RUN apt-get -y install libfltk1.1 libfltk1.1-dev
RUN apt-get -y install libgtk2.0-dev
RUN apt-get -y install libltdl-dev
RUN apt-get -y install libgeos-3.4.2 libgeos-c1 libgeos-dev libgeos++-dev
RUN apt-get -y install libpng12-dev

RUN apt-get -y install subversion git

#Env variables
ENV PLAYER_HOME=/home/player
ENV STAGE_HOME=/home/stage
ENV PATH=$PLAYER_HOME/bin:$STAGE_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$PLAYER_HOME/lib:$STAGE_HOME/lib64:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=$PLAYER_HOME/lib/pkgconfig:$STAGE_HOME/lib64/pkgconfig:$PKG_CONFIG_PATH

RUN echo 'export PLAYER_HOME=/home/player' >> /etc/profile 
RUN echo 'export STAGE_HOME=/home/stage' >> /etc/profile
RUN echo 'export PATH=$PLAYER_HOME/bin:$STAGE_HOME/bin:$PATH' >> /etc/profile
RUN echo 'export LD_LIBRARY_PATH=$PLAYER_HOME/lib:$STAGE_HOME/lib64:$LD_LIBRARY_PATH' >> /etc/profile
RUN echo 'export PKG_CONFIG_PATH=$PLAYER_HOME/lib/pkgconfig:$STAGE_HOME/lib64/pkgconfig:$PKG_CONFIG_PATH' >> /etc/profile

#Install player/stage
RUN mkdir /home/install
RUN cd /home/install && svn checkout svn://svn.code.sf.net/p/playerstage/svn/code/player/trunk player
RUN mkdir -p /home/install/player/build
RUN cd /home/install/player/build && cmake -DCMAKE_INSTALL_PREFIX=$PLAYER_HOME ../ && make && make install

RUN cd /home/install && git clone http://github.com/rtv/Stage.git stage
RUN mkdir -p /home/install/stage/build
RUN cd /home/install/stage/build && cmake -DCMAKE_INSTALL_PREFIX=$STAGE_HOME ../ && make && make install

RUN chown -R docker /home/player
RUN chown -R docker /home/stage

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
