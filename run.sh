#!/usr/bin/env bash

# run publisher image
docker run --detach=true --net=weave --name rti-perftest-pub rti-perftest:latest -pub

# run subscriber image
docker run --detach=true --net=weave --name rti-perftest-sub rti-perftest:latest -sub
