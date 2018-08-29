#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename == *"hdfs-site.xml"* ]]; then
  sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for DataNode--> \
<!-- DataNode security config --> \
    <property> \
         <name>dfs.datanode.data.dir.perm<\/name> \
         <value>750<\/value> \
    <\/property> \
    <property> \
         <name>dfs.datanode.http.address<\/name> \
         <value>0.0.0.0:$PRIV1<\/value> \
    <\/property> \
    <property> \
         <name>dfs.datanode.keytab.file<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
    <\/property> \
    <property> \
         <name>dfs.datanode.kerberos.principal<\/name> \
         <value>hduser\/_HOST@$REALM<\/value> \
    <\/property> \
    <property> \
         <name>dfs.datanode.ipc.address<\/name> \
         <value>0.0.0.0:8010<\/value> \
    <\/property> \
    <property> \
         <name>dfs.datanode.address<\/name> \
         <value>0.0.0.0:$PRIV2<\/value> \
    <\/property> \
    <property> \
         <name>dfs.permissions.supergroup<\/name> \
         <value>hadoop<\/value> \
         <description>The name of the group of super-users.<\/description> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi
