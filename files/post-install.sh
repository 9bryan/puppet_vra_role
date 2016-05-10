#!/bin/bash

PUPPET_MASTER=$1
PUPPET_ROLE=$2

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
#Wait for networking
echo "Waiting for networking (sleeping 120)" &>> /tmp/puppet_install.log
sleep 120

echo "MASTER: ${PUPPET_MASTER}" &>> /tmp/puppet_install.log

mkdir -p /etc/puppetlabs/facter/facts.d &>> /tmp/puppet_install.log
echo "puppet_role: ${PUPPET_ROLE}" > /etc/puppetlabs/facter/facts.d/role.yaml

curl -k "https://${PUPPET_MASTER}:8140/packages/current/install.bash" | bash &>> /tmp/puppet_install.log
