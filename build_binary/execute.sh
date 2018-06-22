#!/usr/bin/env bash

[[ "TRACE" ]] && set -x

cd hadoop-3.1.0-src
mvn package -Pdist,native -DskipTests -Dtar

while true; do sleep 1000; done
