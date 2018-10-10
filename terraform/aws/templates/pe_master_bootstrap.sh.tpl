#!/bin/bash

: ${PE_DOWNLOAD_URI='https://pm.puppet.com/cgi-bin/download.cgi?arch=amd64&dist=ubuntu&rel=18.04&ver=latest'}

msg='Hello from the PE Master bootstrap script!'
logger $msg
echo $msg

set -eux

wget -q -c -O /tmp/pe.tar.gz "${PE_DOWNLOAD_URI}"
mkdir -p /tmp/pe
tar xvf /tmp/pe.tar.gz -C /tmp/pe --strip-components 1
apt-get update
apt-get install -y ruby-hocon
hocon -f /tmp/pe/conf.d/pe.conf set console_admin_password admin
/tmp/pe/puppet-enterprise-installer -c /tmp/pe/conf.d/pe.conf -y

sleep 10
while true; do
    set +e
    puppet agent -t
    if [ "$?" -eq "0" ]; then
	set -e; break
    fi
done
