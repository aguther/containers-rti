#!/usr/bin/env bash

# delete containers
docker rm -f rti-perftest-pub
docker rm -f rti-perftest-sub

# delete image
docker rmi -f rti-perftest
