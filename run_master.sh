#!/bin/bash

docker run -it --cap-add=ALL -e ENABLE_KRB='true' -p 8039:8039 -p 8025:8025 -p 52143:52143 -p 8040:8040 -p 8042:8042 -p 13562:13562 -p 10020:10020 -p 8031:8031 -p 54311:54311 -p 19888:19888 -p 10033:10033 -p 8088:8088 -p 8032:8032 -p 50075:50075 -p 8020:8020 -p 14000:14000 -p 444:44444 -p 50010:50010 -p 2122:2122 -p 50070:50070 -p 54310:54310 -p 50470:50470 -p 50475:50475 --name hdfs-master -h hdfs-master.cloud.com --net cloud.com sumit/hadoop -d master

