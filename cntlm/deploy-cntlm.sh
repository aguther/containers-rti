#!/usr/bin/env bash

# definition of configuration file
CNTLM_CONFIGURATION_FILE=/etc/cntlm.conf

# install cntlm
sudo yum install -y /tmp/cntlm.rpm

# write configuration
sudo echo -e "Proxy\t\t\t$1"		>	$CNTLM_CONFIGURATION_FILE
sudo echo -e "Listen\t\t\t$2" 		>>	$CNTLM_CONFIGURATION_FILE
sudo echo -e "Domain\t\t\t$3" 		>>	$CNTLM_CONFIGURATION_FILE
sudo echo -e "Username\t\t$4"		>>	$CNTLM_CONFIGURATION_FILE
sudo echo -e "Auth\t\t\t$5"			>>	$CNTLM_CONFIGURATION_FILE
sudo echo -e "PassNTLMv2\t\t$6"		>>	$CNTLM_CONFIGURATION_FILE

# start service
sudo systemctl restart cntlm

# deploy proxy configuration for docker
DOCKER_SERVICE_EXTENSION_DIRECTORY=/etc/systemd/system/docker.service.d
DOCKER_PROXY_CONFIGURATION_FILE=$DOCKER_SERVICE_EXTENSION_DIRECTORY/proxy.conf

sudo mkdir -p $DOCKER_SERVICE_EXTENSION_DIRECTORY
sudo echo "[Service]"						>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"HTTP_PROXY=$7\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"HTTPS_PROXY=$8\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"NO_PROXY=$9\""		>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"http_proxy=$7\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"https_proxy=$8\""	>>	$DOCKER_PROXY_CONFIGURATION_FILE
sudo echo "Environment=\"no_proxy=$9\""		>>	$DOCKER_PROXY_CONFIGURATION_FILE
