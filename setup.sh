#!/bin/bash

addgroup hadoop
adduser --ingroup hadoop hduser
adduser hduser sudo

su - hduser -c "ssh-keygen -t rsa -P \"\" -f /home/hduser/.ssh/id_rsa"
su - hduser -c "cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys"

cp /container/ssh_config /home/hduser/.ssh/config
chmod 600 /home/hduser/.ssh/config
chown hduser:hadoop /home/hduser/.ssh/config

echo 'hduser:hadoop' | chpasswd

wget "$REPOSITORY_HOST"/repo/hadoop-2.6.5.tar.gz
tar -xzvf hadoop-2.6.5.tar.gz
mv /usr/local/hadoop-2.6.5 /usr/local/hadoop
rm -rf /usr/local/hadoop-2.6.5.tar.gz
chown -R hduser:hadoop /usr/local/hadoop

su - hduser -c "echo 'export JAVA_HOME=/usr/local/jdk' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_INSTALL=/usr/local/hadoop' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export YARN_HOME=$HADOOP_INSTALL' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_OPTS=\"-Djava.library.path=$HADOOP_INSTALL/lib\"' >> /home/hduser/.bashrc"
su - hduser -c "echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> /home/hduser/.bashrc"
su - hduser -c "echo 'cd /usr/local/hadoop' >> /home/hduser/.bashrc"

su - hduser -c "source /home/hduser/.bashrc"
su - hduser -c "java -version"

sed -i 's/\(export JAVA_HOME=${JAVA_HOME}\)/#\1/' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
sed -i '/export JAVA_HOME/ a\\nexport JAVA_HOME=/usr/local/jdk' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
chown hduser:hadoop /usr/local/hadoop/etc/hadoop/hadoop-env.sh

mkdir -p /app/hadoop/tmp
chown hduser:hadoop /app/hadoop/tmp

mkdir -p /usr/local/hadoop_store/hdfs/namenode
mkdir -p /usr/local/hadoop_store/hdfs/datanode
chown -R hduser:hadoop /usr/local/hadoop_store

cp /container/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
cp /container/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
cp /container/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
cp /container/httpfs-site.xml /usr/local/hadoop/etc/hadoop/httpfs-site.xml
cp /container/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
cp /container/slaves /usr/local/hadoop/etc/hadoop/slaves
chown hduser:hadoop /usr/local/hadoop/etc/hadoop/hdfs-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml /usr/local/hadoop/etc/hadoop/slaves /usr/local/hadoop/etc/hadoop/httpfs-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

su - hduser -c "$HADOOP_INSTALL/bin/hdfs namenode -format"

cp /container/bootstrap.sh /etc/bootstrap.sh
chown hduser:hadoop /etc/bootstrap.sh
chmod 700 /etc/bootstrap.sh


su - hduser -c "echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /home/hduser/.bashrc"

# workingaround docker.io build error
ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

mkdir $HADOOP_INSTALL/input
cp $HADOOP_INSTALL/etc/hadoop/*.xml $HADOOP_INSTALL/input
chown hduser:hadoop $HADOOP_INSTALL/input

