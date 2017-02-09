FROM debian:wheezy

# Set locale (fix the locale warnings)
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8


# User accounts
RUN echo 'root:root' | chpasswd \
	&& useradd -m docker \
	&& echo 'docker:docker' | chpasswd \
	&& usermod -s /bin/bash docker \
	&& usermod -aG sudo docker 
ENV HOME /home/docker

# Install packages required by player/stage
RUN apt-get update && apt-get -y install autotools-dev build-essential cmake cpp libtool \
	libboost-thread1.49.0 libboost-thread1.49-dev libboost-signals1.49.0 libboost-signals1.49-dev \
	libcv2.3 libcv-dev libcvaux2.3 libcvaux-dev libgnomecanvas2-dev libgnomecanvasmm-2.6-1c2a libgnomecanvasmm-2.6-dev \
	libgsl0-dev libgsm1 libhighgui-dev libraw1394-dev libxmu-dev swig python-dev robot-player \
	freeglut3 freeglut3-dev libfltk1.3 libfltk1.3-dev libgtk2.0-dev libltdl-dev \
	libgeos-3.3.3 libgeos-c1 libgeos-dev libgeos++-dev libpng12-dev \
	subversion git

#Env variables
ENV PLAYER_HOME=/home/player
ENV STAGE_HOME=/home/stage
ENV PATH=$PLAYER_HOME/bin:$STAGE_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$PLAYER_HOME/lib:$STAGE_HOME/lib64:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=$PLAYER_HOME/lib/pkgconfig:$STAGE_HOME/lib64/pkgconfig:$PKG_CONFIG_PATH

RUN echo 'export PLAYER_HOME=/home/player' >> /etc/profile \
	&& echo 'export STAGE_HOME=/home/stage' >> /etc/profile \
	&& echo 'export PATH=$PLAYER_HOME/bin:$STAGE_HOME/bin:$PATH' >> /etc/profile \
	&& echo 'export LD_LIBRARY_PATH=$PLAYER_HOME/lib:$STAGE_HOME/lib64:$LD_LIBRARY_PATH' >> /etc/profile \
	&& echo 'export PKG_CONFIG_PATH=$PLAYER_HOME/lib/pkgconfig:$STAGE_HOME/lib64/pkgconfig:$PKG_CONFIG_PATH' >> /etc/profile

#Install player/stage
RUN mkdir /home/install \
	&& cd /home/install && svn checkout svn://svn.code.sf.net/p/playerstage/svn/code/player/trunk player \
	&& mkdir -p /home/install/player/build \
	&& cd /home/install/player/build && cmake -DCMAKE_INSTALL_PREFIX=$PLAYER_HOME ../ && make && make install

RUN cd /home/install && git clone http://github.com/rtv/Stage.git stage \
	&& mkdir -p /home/install/stage/build \
	&& cd /home/install/stage/build && cmake -DCMAKE_INSTALL_PREFIX=$STAGE_HOME ../ && make && make install

RUN chown -R docker /home/player && chown -R docker /home/stage \
	&& rm -rf /home/install

CMD ["/bin/bash"]