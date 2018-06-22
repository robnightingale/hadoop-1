#!/bin/bash

#ssh hduser@localhost -p 2122
source configuration
docker exec -it $CONTAINER_NAME /bin/bash
