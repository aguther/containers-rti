#!/usr/bin/env bash

function usage()
{
    echo ""
    echo "Script to deploy and start a local Kubernetes Cluster"
    echo ""
    echo "./vagrant-deploy-kubernetes.sh"
    echo -e "\t-h | --help\t\t\tPrint usage"
    echo -e "\t-p | --playbook=n\t\t[OPTIONAL] Playbook to execute\t\t\t(deploy-kubernetes.yml)"
    echo -e "\t-i | --instances=n\t\t[OPTIONAL] Number of instances\t\t\t(2)"
    echo -e "\t-c | --cpus=n\t\t\t[OPTIONAL] Number of CPUs per instance\t\t(3)"
    echo -e "\t-m | --memory=n\t\t\t[OPTIONAL] Size of memory in MB per instance\t(4096)"
    echo -e "\t--proxy=http://IP:PORT\t\t[OPTIONAL] Network proxy to be used\t\t(None)"
    echo ""
}

# defaults
export PLAYBOOK=deploy-kubernetes.yml
export VM_INSTANCES=2
export VM_CPUS=3
export VM_MEMORY=4096

# parse command line arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -i | --instances)
            VM_INSTANCES=$VALUE
            ;;
        -c | --cpus)
            VM_CPUS=$VALUE
            ;;
        -m | --memory)
            VM_MEMORY=$VALUE
            ;;
        -p | --playbook)
            PLAYBOOK=$VALUE
            ;;
        --proxy)
            VM_PROXY=$VALUE
            ;;
        -d | --destroy-only)
            DESTROY_ONLY=TRUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# print configuration
echo
echo Deployment configuration:
echo VM_INSTANCES=${VM_INSTANCES}
echo VM_CPUS=${VM_CPUS}
echo VM_MEMORY=${VM_MEMORY}
if [[ -v VM_PROXY ]]; then
    echo VM_PROXY=${VM_PROXY}
fi
echo
echo PLAYBOOK=${PLAYBOOK}
echo

# destroy current vms
vagrant destroy -f
if [ $? -ne 0 ]; then
    echo
    echo "[ERROR] vagrant destroy failed"
    echo
    exit 1
fi

# check if user only wanted destroy of vms
if [ "$DESTROY_ONLY" = "TRUE" ]; then
    exit 0
fi

# create and start vms
vagrant up
if [ $? -ne 0 ]; then
    echo
    echo "[ERROR] vagrant up failed"
    echo
    exit 1
fi

# copy existing kubectl config (so we can merge)
mkdir -p .kube
cp -f ~/.kube/config .kube/config

# get cluster config and merge it with ours
./vagrant-playbook.sh kubernetes-copy-config.yml

# copy config back
mkdir -p ~/.kube
cp -f .kube/config ~/.kube/config
