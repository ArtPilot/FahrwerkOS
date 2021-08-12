#!/bin/bash
docker buildx build --platform linux/arm64/v8,linux/amd64 --tag registry.al0.de/artpilot/ros:melodic  . --push
