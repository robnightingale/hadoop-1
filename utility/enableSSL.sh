#!/bin/bash

[[ "TRACE" ]] && set -x

source /configg/hadoop/config

filename=$1

if [[ $filename = *"hdfs-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable SSL--> \
    <property> \
         <name>dfs.http.policy<\/name> \
         <value>HTTPS_ONLY<\/value> \
    <\/property> \
    <property> \
         <name>dfs.data.transfer.protection<\/name> \
         <value>authentication<\/value> \
     <\/property> \
     <property> \
         <name>dfs.encrypt.data.transfer<\/name> \
         <value>true<\/value> \
     <\/property> \
     <property> \
         <name>dfs.client.https.need-auth<\/name> \
         <value>false<\/value> \
     <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
elif [[ $filename = *"mapred-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable SSL--> \
    <property> \
         <name>mapreduce.shuffle.ssl.enabled<\/name> \
         <value>true<\/value> \
     <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
elif [[ $filename = *"core-site.xml"* ]]
then
 sed -i 's/<\/configuration>/<!-- Enable SSL--> \
    <property> \
        <name>hadoop.ssl.require.client.cert<\/name> \
        <value>false<\/value> \
    <\/property> \
<!-- Inorder to skip hostname check from the certificate, keep it ALLOW_ALL--> \
    <property> \
        <name>hadoop.ssl.hostname.verifier<\/name> \
        <value>DEFAULT<\/value> \
    <\/property> \
    <property> \
        <name>hadoop.ssl.keystores.factory.class<\/name> \
        <value>org.apache.hadoop.security.ssl.FileBasedKeyStoresFactory<\/value> \
    <\/property> \
    <property> \
        <name>hadoop.ssl.server.conf<\/name> \
        <value>ssl-server.xml<\/value> \
    <\/property> \
    <property> \
        <name>hadoop.ssl.client.conf<\/name> \
        <value>ssl-client.xml<\/value> \
    <\/property> \
    <property> \
        <name>hadoop.rpc.protection<\/name> \
        <value>privacy<\/value> \
    <\/property> \
<!-- End --> \
<\/configuration>/g' $filename
fi



