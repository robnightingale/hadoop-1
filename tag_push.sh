#!/bin/bash

source config
docker tag $IMAGE_NAME $REGISTRY/$REPO_NAME
docker push $REGISTRY/$REPO_NAME
