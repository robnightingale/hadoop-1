#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename = *"httpfs-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable Kerberos authentication for httfs--> \
<property> \
  <name>httpfs.authentication.type<\/name> \
  <value>kerberos<\/value> \
<\/property> \
<property> \
  <name>httpfs.hadoop.authentication.type<\/name> \
  <value>kerberos<\/value> \
<\/property> \
<property> \
  <name>httpfs.authentication.kerberos.principal<\/name> \
  <value>HTTP\/$HDFS_MASTER@$REALM<\/value> \
<\/property> \
<property> \
  <name>httpfs.authentication.kerberos.keytab<\/name> \
  <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
<\/property> \
<property> \
  <name>httpfs.hadoop.authentication.kerberos.principal<\/name> \
  <value>hduser\/$HDFS_MASTER@$REALM<\/value> \
<\/property> \
<property> \
  <name>httpfs.hadoop.authentication.kerberos.keytab<\/name> \
  <value>\/etc\/security\/keytabs\/hduser.keytab<\/value> \
<\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi

