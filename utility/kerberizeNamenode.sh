#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename == *"core-site.xml"* ]]; then
  sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication--> \
    <property> \
         <name>hadoop.security.authentication<\/name> \
         <value>kerberos<\/value> \
         <description> Set the authentication for the cluster. \
         Valid values are: simple or kerberos.<\/description> \
    <\/property> \
    <property> \
         <name>hadoop.security.authorization<\/name> \
         <value>true<\/value> \
         <description>Enable authorization for different protocols.<\/description> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
elif [[ $filename == *"hdfs-site.xml"* ]]; then
  sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for Namenode--> \
<!-- General HDFS security config --> \
    <property> \
         <name>dfs.block.access.token.enable<\/name> \
         <value>true<\/value> \
         <description> If \"true\", access tokens are used as capabilities \
            for accessing datanodes. If \"false\", no access tokens are checked on \
            accessing datanodes. <\/description> \
    <\/property> \
<!-- NameNode security config --> \
    <property> \
         <name>dfs.namenode.keytab.file<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> <!-- path to the HDFS keytab --> \
    <\/property> \
    <property> \
         <name>dfs.namenode.kerberos.principal<\/name> \
          <value>hduser\/_HOST@$REALM<\/value> \
    <\/property> \
    <property> \
         <name>dfs.namenode.kerberos.internal.spnego.principal<\/name> \
         <value>HTTP\/_HOST@$REALM<\/value> \
    <\/property> \
<!-- Web Authentication config --> \
    <property> \
         <name>dfs.web.authentication.kerberos.principal<\/name> \
         <value>HTTP\/_HOST@$REALM<\/value> \
    <\/property> \
    <property> \
         <name>dfs.web.authentication.kerberos.keytab<\/name> \
         <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
         <description>The Kerberos keytab file with the credentials for the HTTP \
         Kerberos principal used by Hadoop-Auth in the HTTP endpoint. \
         <\/description> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi
