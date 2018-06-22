#!/bin/bash
source ./config/config
source configuration

docker build --build-arg REPOSITORY_HOST=$REPOSITORY_HOST -t $IMAGE_NAME .
