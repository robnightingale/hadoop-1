#!/bin/bash

[[ "TRACE" ]] && set -x

: ${HADOOP_INSTALL:=/usr/local/hadoop}

startSsh() {
 echo -e "Starting SSHD service"
 /usr/sbin/sshd
}

setEnvVariable() {
 echo 'export JAVA_HOME=/usr/local/jdk' >> /home/users/$1/.bashrc
 echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/users/$1/.bashrc
 echo 'export HADOOP_INSTALL=/usr/local/hadoop' >> /home/users/$1/.bashrc
 echo 'export PATH=$PATH:$HADOOP_INSTALL/bin' >> /home/users/$1/.bashrc
 echo 'export PATH=$PATH:$HADOOP_INSTALL/sbin' >> /home/users/$1/.bashrc
 echo 'export HADOOP_MAPRED_HOME=$HADOOP_INSTALL' >> /home/users/$1/.bashrc
 echo 'export HADOOP_COMMON_HOME=$HADOOP_INSTALL' >> /home/users/$1/.bashrc
 echo 'export HADOOP_HDFS_HOME=$HADOOP_INSTALL' >> /home/users/$1/.bashrc
 echo 'export YARN_HOME=$HADOOP_INSTALL' >> /home/users/$1/.bashrc
 echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /home/users/$1/.bashrc
 echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib/native"' >> /home/users/$1/.bashrc
 echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> /home/users/$1/.bashrc
 echo 'export LD_LIBRARY_PATH=/usr/local/lib:$HADOOP_INSTALL/lib/native:$LD_LIBRARY_PATH' >> /home/users/$1/.bashrc
 echo 'cd /usr/local/hadoop' >> /home/users/$1/.bashrc
}

changeOwner() {
 chown -R hduser:hadoop /app/hadoop/tmp
 chown -R hduser:hadoop /usr/local/hadoop_store
 chown -R hduser:hadoop /usr/local/hadoop
}

initializePrincipal() {
 kadmin -p root/admin -w admin -q "addprinc -pw sumit root@CLOUD.COM"
 kadmin -p root/admin -w admin -q "addprinc -randkey hduser/$(hostname -f)@CLOUD.COM"
 kadmin -p root/admin -w admin -q "addprinc -randkey HTTP/$(hostname -f)@CLOUD.COM"
 
 kadmin -p root/admin -w admin -q "xst -k hduser.keytab hduser/$(hostname -f)@CLOUD.COM HTTP/$(hostname -f)@CLOUD.COM"

 mkdir -p /etc/security/keytabs
 mv hduser.keytab /etc/security/keytabs
 chmod 400 /etc/security/keytabs/hduser.keytab
 chown hduser:hadoop /etc/security/keytabs/hduser.keytab
}


startMaster() {
su - hduser -c "$HADOOP_INSTALL/etc/hadoop/hadoop-env.sh"
su - hduser -c "$HADOOP_INSTALL/sbin/hadoop-daemon.sh start namenode"
su - hduser -c "$HADOOP_INSTALL/sbin/hadoop-daemon.sh start datanode"
#su - root -c "$HADOOP_INSTALL/sbin/start-all.sh"
# su - root -c "$HADOOP_INSTALL/sbin/mr-jobhistory-daemon.sh start historyserver --config /usr/local/hadoop/etc/hadoop"
# su - root -c "$HADOOP_INSTALL/bin/hdfs dfs -mkdir -p /user/hduser"
# su - root -c "$HADOOP_INSTALL/bin/hdfs dfs -mkdir -p /user/hue"
# su - root -c "$HADOOP_INSTALL/bin/hdfs dfs -chmod g+w /user/hduser"
# su - root -c "$HADOOP_INSTALL/bin/hdfs dfs -chmod g+w /user/hue"
# su - root -c "$HADOOP_INSTALL/sbin/httpfs.sh start"
}

startSlave() {
 su - root -c "$HADOOP_INSTALL/etc/hadoop/hadoop-env.sh"
# su - root -c "$HADOOP_INSTALL/sbin/hadoop-daemon.sh --config /usr/local/hadoop/etc/hadoop --script hdfs start datanode"
# su - root -c "$HADOOP_INSTALL/sbin/yarn-daemons.sh --config /usr/local/hadoop/etc/hadoop  start nodemanager"
}

deamon() {
  while true; do sleep 1000; done
}

bashPrompt() {
 /bin/bash
}

sshPromt() {
 /usr/sbin/sshd -D
}

initialize() {
   if [[ $1 == 'master' ]] 
   then
su - hduser -c "$HADOOP_INSTALL/bin/hdfs namenode -format"
    startMaster
   elif [[ $1 == 'slave' ]]
   then
    startSlave
   fi
}

main() {
 if [ ! -f /hadoop_initialized ]; then
    /utility/ldap/bootstrap.sh
    startSsh
    su - hduser -c "echo 'Initiating......'"
    initializePrincipal
    changeOwner
    setEnvVariable hduser
    initialize $2
    touch /hadoop_initialized
  else
    startSsh
    initialize $2
  fi
  if [[ $1 == "-d" ]]; then
   deamon
  fi

}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
