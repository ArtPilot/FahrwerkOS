#!/bin/bash
echo "Starting"
source /opt/ros/noetic/setup.bash
source /catkin_ws/devel/setup.bash
roscore & #>/dev/null &
roslaunch rplidar_ros rplidar.launch & #>/dev/null &
roslaunch cartographer_ros cartographer.launch & #>/dev/null &
roslaunch mavros px4.launch & #>/dev/null &
sleep 10
tail -f /root/.ros/logs/**/*
