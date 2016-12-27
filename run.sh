#!/usr/bin/env bash

# run combined images
docker run --detach=true --name rti-perftest-pub rti-perftest:latest -pub -sleep 1000
docker run --detach=true --name rti-perftest-sub rti-perftest:latest -sub

# run combined images with weave
#docker run --detach=true --net=weave --name rti-perftest-pub rti-perftest:latest -pub -sleep 1000
#docker run --detach=true --net=weave --name rti-perftest-sub rti-perftest:latest -sub
