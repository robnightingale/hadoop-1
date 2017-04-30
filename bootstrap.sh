#!/bin/bash

: ${HADOOP_INSTALL:=/usr/local/hadoop}

$HADOOP_INSTALL/etc/hadoop/hadoop-env.sh


echo -e "Initiating Hadoop"

echo -e "Starting SSHD service"
/usr/sbin/sshd

if [[ $2 == "master" ]]; then
su - hduser -c "$HADOOP_INSTALL/sbin/start-all.sh"
fi

if [[ $2 == "slave" ]]; then
su - hduser -c "$HADOOP_INSTALL/sbin/hadoop-daemon.sh start datanode"
su - hduser -c "$HADOOP_INSTALL/sbin/yarn-daemons.sh --config /usr/local/hadoop/etc/hadoop  start nodemanager"
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
su - hduser -c "/bin/bash"
fi

if [[ $1 == "-ssh" ]]; then
/usr/sbin/sshd -D
fi

