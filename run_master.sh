#!/bin/bash

docker run -d -h node01  --name consul -p 8300:8300 -p 8301:8301 -p 8301:8301/udp -p 8302:8302 -p 8302:8302/udp -p 8400:8400 -p 8500:8500 -p 53:53/udp progrium/consul -server -advertise 11.0.0.2 -bootstrap-expect 2

docker run -d -v /var/run/docker.sock:/tmp/docker.sock --link consul:consul --name registrator -h registrator gliderlabs/registrator:latest consul://11.0.0.2:8500

docker run -d -p 56000-56020:56000-56020 -p 8025:8025 -p 52143:52143 -p 8040:8040 -p 8042:8042 -p 13562:13562 -p 10020:10020 -p 8031:8031 -p 54311:54311 -p 19888:19888 -p 10033:10033 -p 8088:8088 -p 8032:8032 -p 50075:50075 -p 8020:8020 -p 14000:14000 -p 444:44444 -p 50010:50010 -p 2122:2122 -p 50070:50070 -p 54310:54310 --dns 172.17.0.2 --dns 8.8.8.8 --dns-search service.consul -e "SERVICE_2122_NAME=node01" -e "SERVICE_2122_ID=node01.2122" --name hadoop -h node01 sumit/hadoop:latest /etc/bootstrap.sh -d master 

