#!/bin/bash
echo "Starting"
source /opt/ros/noetic/setup.bash
source /catkin_ws/devel/setup.bash
roscore &>/dev/null &
#roslaunch --wait gbot_core gbot.launch &>/dev/null &
#roslaunch --wait mavros apm.launch gcs_url:=udp://@192.168.100.113:14550 &>/dev/null &
#sleep 5
#roslaunch --wait astra_camera astrapro.launch &>/dev/null &
rosrun web_video_server web_video_server %>/dev/null &
sleep 5
tail -f /root/.ros/log/**/*
