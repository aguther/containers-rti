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
sudo echo -e "NoProxy\t\t\t$7"		>>	$CNTLM_CONFIGURATION_FILE

# start service
sudo systemctl restart cntlm
