#!/bin/bash
source ./config/config
source configuration

docker build --build-arg REPOSITORY_HOST=$REPOSITORY_HOST --build-arg HADOOP_VERSION=$HADOOP_VERSION -t $IMAGE_NAME .
