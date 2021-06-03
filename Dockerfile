FROM ros:noetic-ros-base-focal

# TODO: run as user
# this user needs to be in dialout sudo usermod -a -G dialout 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    ; apt-get install -y curl git ninja-build stow
RUN bash -c 'curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - '

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && mkdir -p /catkin_ws/src"
WORKDIR /catkin_ws

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && cd src \
    && git clone --depth 1 https://github.com/robopeak/rplidar_ros \
    && git clone --depth 1 https://github.com/GT-RAIL/robot_pose_publisher.git \
    && sed -i 's/is_stamped, false/is_stamped, true/g' robot_pose_publisher/src/robot_pose_publisher.cpp"

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && apt-get update \
    && wstool init src \
    && wstool merge -t src https://raw.githubusercontent.com/cartographer-project/cartographer_ros/master/cartographer_ros.rosinstall \
    && wstool update -t src \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y \
    && ./src/cartographer/scripts/install_abseil.sh"
    # && catkin_make_isolated --install --use-ninja"

## install mavproxy and mavros
RUN bash -c "source /opt/ros/noetic/setup.bash \
    && apt-get install -y python3-dev python3-opencv python3-wxgtk4.0 python3-pip python3-matplotlib python3-lxml python3-pygame \
    && pip3 install PyYAML mavproxy \
    && apt-get install -y ros-noetic-mavros ros-noetic-mavros-extras  python3-catkin-tools python3-catkin-lint python3-pip \
    && /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh \
    && pip3 install osrf-pycommon"

COPY ./cartographer.launch /catkin_ws/src/cartographer_ros/cartographer_ros/launch
COPY ./cartographer.lua /catkin_ws/src/cartographer_ros/cartographer_ros/configuration_files

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && apt install -y ros-*-rgbd-launch ros-*-libuvc-camera \
    && cd  /catkin_ws/src \
    && git clone --depth 1 https://github.com/orbbec/ros_astra_camera"

## install mavproxy and mavros
# TODO: enable hardware flow contrll in px4.launch
# to rename the mavros serial device
#     # && sed -i \"s/ttyACM0/pixhawk/\" ./px4.launch \
# TODO: quote the xml params in remap from singe to double
RUN bash -c "source /opt/ros/noetic/setup.bash \
    && roscd mavros/launch \
    && sed -i \"/<\/node>/i\\\<remap from='\/mavros\/vision_pose\/pose\' to='\/robot_pose' \/\>\" ./node.launch \
    && sed -i \"s/timesync_rate: 10.0/timesync_rate: 0.0/\" ./px4_config.yaml \
    && cd /catkin_ws \
    && catkin build\
    && source devel/setup.bash"

RUN apt-get purge -y modemmanager
COPY bashrc.bash /root/.ros_bashrc