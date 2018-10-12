#!/bin/bash

: ${PE_DOWNLOAD_URI='https://pm.puppet.com/cgi-bin/download.cgi?arch=amd64&dist=ubuntu&rel=18.04&ver=latest'}

msg='Hello from the PE Master bootstrap script!'
logger $msg
echo $msg

set -eux

wget -q -c -O /tmp/pe.tar.gz "${PE_DOWNLOAD_URI}"
mkdir -p /tmp/pe
tar xvf /tmp/pe.tar.gz -C /tmp/pe --strip-components 1

command -v hocon && command -v facter
if [ "0" -ne "$?" ]; then
    apt-get update
    apt-get install -y ruby-hocon facter
fi

public_hostname="$(facter ec2_metadata.public-hostname)"
hocon -f /tmp/pe/conf.d/pe.conf set console_admin_password vault-puppet-demo
hocon -f /tmp/pe/conf.d/pe.conf set pe_install\"::\"puppet_master_dnsaltnames "[ \"${public_hostname}\" ]"
/tmp/pe/puppet-enterprise-installer -c /tmp/pe/conf.d/pe.conf -y

sleep 10

while true; do
    set +e
    puppet agent -t
    if [ "$?" -eq "0" ]; then
	set -e; break
    fi
done
