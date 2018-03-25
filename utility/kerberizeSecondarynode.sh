#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename = *"hdfs-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for SecondaryNameNode--> \
<!-- Secondary NameNode security config --> \
    <property> \
         <name>dfs.secondary.namenode.kerberos.principal<\/name> \
         <value>hduser\/_HOST@$REALM<\/value> \
         <description>Kerberos principal name for the secondary NameNode. \
         <\/description> \
    <\/property> \
    <property> \
         <name>dfs.secondary.namenode.keytab.file<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
         <description> \
         Combined keytab file containing the namenode service and host \
         principals. \
         <\/description> \
    <\/property> \
    <property> \
<!--cluster variant --> \
         <name>dfs.secondary.http.address<\/name> \
         <value>$HDFS_MASTER:50090<\/value> \
         <description>Address of secondary namenode web server<\/description> \
    <\/property> \
    <property> \
         <name>dfs.secondary.https.port<\/name> \
         <value>50490<\/value> \
         <description>The https port where secondary-namenode binds<\/description> \
    <\/property> \
    <property> \
         <name>dfs.secondary.namenode.kerberos.internal.spnego.principal<\/name> \
         <value>$\{dfs.web.authentication.kerberos.principal\}<\/value> \
     <\/property> \
     <property> \
         <name>dfs.secondary.namenode.kerberos.http.principal<\/name> \
          <value>HTTP\/_HOST@$REALM<\/value> \
     <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi

