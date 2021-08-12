FROM ros:melodic
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y \
                    curl \
                    git \
                    iputils-ping \
                    ninja-build \
                    nmap \
                    stow \
                    tcpdump \
                    vim
RUN apt-get install -y ros-melodic-mavros ros-melodic-mavros-extras
RUN curl -s https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh | bash
RUN apt-get install -y python-catkin-tools