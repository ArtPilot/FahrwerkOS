FROM ros:noetic-ros-base-focal

# TODO: run as user
# this user needs to be in dialout sudo usermod -a -G dialout 
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'source /opt/ros/noetic/setup.bash' >> $HOME/.bashrc \
    && mkdir -p /catkin_ws/src
WORKDIR /catkin_ws

COPY ./02nocache /etc/apt/apt.conf.d/02nocache
COPY ./01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN apt-get update \
    && apt-get install -y curl git ninja-build stow vim nmap tcpdump\
    && rm -rf /var/cache/apt/archives 

RUN rm -rf /usr/share/doc/ /usr/share/man/ /usr/share/locale/

# Install ROS Private Key
RUN bash -c 'curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - '
RUN apt-get update

COPY dependencies.rosinstall /dependencies.rosinstall
RUN bash -c "wstool init src /dependencies.rosinstall \
             && wstool update -t src \
            #  && sed -i 's/is_stamped, false/is_stamped, true/g' src/robot_pose_publisher/src/robot_pose_publisher.cpp \
             && sed -i 's/libuvc/libuvc-dev/' src/ros_astra_camera/package.xml" 

RUN rosdep update
RUN rosdep install --from-paths src/rplidar_ros --rosdistro=${ROS_DISTRO} -y
RUN rosdep install --from-paths src/ros_astra_camera --rosdistro=${ROS_DISTRO} -y
RUN rosdep install --from-paths src/cartographer --rosdistro=${ROS_DISTRO} -y

RUN bash -c "rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y"
RUN bash -c "./src/cartographer/scripts/install_abseil.sh"

# ## install mavproxy and mavros
RUN bash -c "apt-get install -y python3-dev python3-opencv python3-wxgtk4.0 python3-pip python3-matplotlib python3-lxml python3-pygame \
    && pip3 install PyYAML mavproxy \
    && apt-get install -y ros-noetic-mavros ros-noetic-mavros-extras  python3-catkin-tools python3-catkin-lint python3-pip ros-robot-state-publisher \
    && /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh \
    && pip3 install osrf-pycommon"

# # TODO: enable hardware flow contrll in px4.launch
# # to rename the mavros serial device
# #     # && sed -i \"s/ttyACM0/pixhawk/\" ./px4.launch \
# # TODO: quote the xml params in remap from singe to double
RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash \
    && roscd mavros/launch \
    && sed -i \"s/timesync_rate: 10.0/timesync_rate: 0.0/\" ./apm_config.yaml"
    #&& sed -i \"/<\/node>/i\\\<remap from='\/mavros\/vision_pose\/pose\' to='\/robot_pose' \/\>\" ./node.launch \
    #&& sed -i \"s/timesync_rate: 10.0/timesync_rate: 0.0/\" ./apm_config.yaml"

# COPY ./cartographer.launch /catkin_ws/src/cartographer_ros/cartographer_ros/launch
# COPY ./cartographer.lua /catkin_ws/src/cartographer_ros/cartographer_ros/configuration_files

RUN apt-get purge -y modemmanager \
    && apt-get autoremove -y
RUN bash -c "source /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash; catkin build rplidar_ros"
RUN bash -c "source /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash; catkin build cartographer"
RUN bash -c "source /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash; catkin build cartographer_ros"
RUN bash -c "source /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash; catkin build"
RUN bash -c "echo 'source /catkin_ws/devel/setup.bash' >> /root/.bashrc"
RUN bash -c "source /catkin_ws/devel/setup.bash\
             && roscd astra_camera/launch \
             && sed -i 's/0x0501/0x0502/' ./astrapro.launch" 

RUN apt-get autoremove -y
RUN apt-get install -y ros-noetic-web-video-server ros-noetic-usb-cam libcamera-info-manager0d ros-noetic-cv-camera ros-noetic-video-stream-opencv