#!/bin/bash
source ./config/config

docker build --build-arg REPOSITORY_HOST=$REPOSITORY_HOST -t sumit/hadoop:latest .
