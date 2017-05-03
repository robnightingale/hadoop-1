#!/bin/bash

: ${HADOOP_INSTALL:=/usr/local/hadoop}

$HADOOP_INSTALL/etc/hadoop/hadoop-env.sh


echo -e "Initiating Hadoop"

echo -e "Starting SSHD service"
/usr/sbin/sshd

if [[ $2 == "master" ]]; then
su - hduser -c "$HADOOP_INSTALL/sbin/start-all.sh"
su - hduser -c "$HADOOP_INSTALL/sbin/mr-jobhistory-daemon.sh start historyserver --config /usr/local/hadoop/etc/hadoop"
su - hduser -c "$HADOOP_INSTALL/bin/hdfs dfs -mkdir -p /user/hduser"
su - hduser -c "$HADOOP_INSTALL/bin/hdfs dfs -mkdir -p /user/hue"
su - hduser -c "$HADOOP_INSTALL/bin/hdfs dfs -chmod g+x /user/hduser"
su - hduser -c "$HADOOP_INSTALL/bin/hdfs dfs -chmod g+x /user/hue"
su - hduser -c "$HADOOP_INSTALL/sbin/httpfs.sh start"
fi

if [[ $2 == "slave" ]]; then
su - hduser -c "$HADOOP_INSTALL/sbin/hadoop-daemon.sh --config /usr/local/hadoop/etc/hadoop --script hdfs start datanode"
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

