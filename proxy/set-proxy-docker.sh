#!/usr/bin/env bash

# deploy proxy configuration for docker
DOCKER_SERVICE_EXTENSION_DIRECTORY=/etc/systemd/system/docker.service.d
DOCKER_PROXY_CONFIGURATION_FILE=$DOCKER_SERVICE_EXTENSION_DIRECTORY/proxy.conf

sudo mkdir -p $DOCKER_SERVICE_EXTENSION_DIRECTORY
sudo echo "[Service]"						>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"http_proxy=$1\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"HTTP_PROXY=$1\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"https_proxy=$1\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"HTTPS_PROXY=$1\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"no_proxy=$2\""	    >>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"NO_PROXY=$2\""	    >>	$DOCKER_PROXY_CONFIGURATION_FILE
