#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename = *"yarn-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for Yarn--> \
<!-- yarn process --> \
    <property> \
         <name>yarn.nodemanager.container-executor.class<\/name> \
         <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor<\/value> \
    <\/property> \
    <property> \
         <name>yarn.nodemanager.linux-container-executor.group<\/name> \
         <value>hduser<\/value> \
    <\/property> \
<!-- resource manager secure configuration info --> \
    <property> \
         <name>yarn.resourcemanager.principal<\/name> \
         <value>hduser\/_HOST@$REALM<\/value> \
    <\/property> \
    <property> \
         <name>yarn.resourcemanager.keytab<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
    <\/property> \
<!-- NodeManager --> \
    <property> \
         <name>yarn.nodemanager.principal<\/name> \
         <value>hduser\/_HOST@$REALM<\/value> \
    <\/property> \
    <property> \
         <name>yarn.nodemanager.keytab<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
elif [[ $filename = *"mapred-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for Yarn--> \
    <property> \
         <name>mapreduce.jobhistory.keytab<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
    <\/property> \
    <property> \
         <name>mapreduce.jobhistory.principal<\/name> \
         <value>hduser\/_HOST@$REALM<\/value> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi

