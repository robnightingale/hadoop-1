#!/bin/bash
docker build --build-arg REPOSITORY_HOST=http://192.168.1.5 \
-v /home/sumit/repository/repository:/usr/lib/repository \
-t sumit/build:latest .
