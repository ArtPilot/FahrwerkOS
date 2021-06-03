#!/bin/bash
source /opt/ros/noetic/setup.bash
source devel/setup.bash
roscore & #>/dev/null &
roslaunch rplidar_ros rplidar.launch & #>/dev/null &
roslaunch cartographer_ros cartographer.launch & #>/dev/null &
roslaunch mavros px4.launch & #>/dev/null &