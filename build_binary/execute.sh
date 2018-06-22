#!/usr/bin/env bash

[[ "TRACE" ]] && set -x

cd hadoop-3.1.0-src
mvn package -Pdist,native -DskipTests -Dtar
