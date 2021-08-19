#!/bin/bash
echo "Starting"
source /opt/ros/noetic/setup.bash
source /catkin_ws/devel/setup.bash
roscore &>/dev/null &
roslaunch --wait rplidar_ros rplidar.launch &>/dev/null &
roslaunch --wait cartographer_ros cartographer.launch &>/dev/null &
roslaunch --wait mavros apm.launch gcs_url:=udp://@192.168.100.113:14550 &>/dev/null &
sleep 5
tail -f /root/.ros/log/**/*
