FROM ros:noetic-ros-base-focal

# TODO: run as user
# this user needs to be in dialout sudo usermod -a -G dialout 

RUN apt-get update \
    ; apt-get install -y curl git ninja-build stow
RUN bash -c 'curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - '

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && mkdir -p /catkin_ws/src \
    && cd /catkin_ws/ \
    && catkin_make"

WORKDIR /catkin_ws

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && source /catkin_ws/devel/setup.sh \
    && cd src \
    && git clone --depth 1 https://github.com/robopeak/rplidar_ros \
    && cd .. \
    && catkin_make"

RUN bash -c "source /opt/ros/noetic/setup.bash \
    && source /catkin_ws/devel/setup.sh \
    && apt-get update \
    && wstool init src \
    && wstool merge -t src https://raw.githubusercontent.com/cartographer-project/cartographer_ros/master/cartographer_ros.rosinstall \
    && wstool update -t src \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y \
    && ./src/cartographer/scripts/install_abseil.sh \
    && catkin_make_isolated --install --use-ninja"

## install mavproxy and mavros
RUN bash -c "source /opt/ros/noetic/setup.bash \
    && source /catkin_ws/devel/setup.sh \
    && apt-get install -y python3-dev python3-opencv python3-wxgtk4.0 python3-pip python3-matplotlib python3-lxml python3-pygame \
    && pip3 install PyYAML mavproxy \
    && apt-get install -y ros-noetic-mavros ros-noetic-mavros-extras  python3-catkin-tools python3-catkin-lint python3-pip \
    && /opt/ros/noetic/lib/mavros/install_geographiclib_datasets.sh \
    && pip3 install osrf-pycommon"

COPY ./cartographer.launch /catkin_ws/src/cartographer_ros/cartographer_ros/launch
COPY ./cartographer.lua /catkin_ws/src/cartographer_ros/cartographer_ros/configuration_files

## install mavproxy and mavros
RUN bash -c "source /opt/ros/noetic/setup.bash \
    && source /catkin_ws/devel/setup.sh \
    && cd src \
    && git clone --depth 1 https://github.com/GT-RAIL/robot_pose_publisher.git \
    && sed -i 's/is_stamped, false/is_stamped, true/g' robot_pose_publisher/src/robot_pose_publisher.cpp \
    && roscd mavros/launch \
    && sed -i \"/<\/node>/i\\\<remap from=\"\/mavros\/vision_pose\/pose\" to=\"\/robot_pose\" \/\>\" ./node.launch \
    && cd /catkin_ws \
    && catkin build"

