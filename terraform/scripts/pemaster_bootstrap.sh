: ${PAPERTRAIL_TOKEN=$${papertrail_token}}
: ${PE_DOWNLOAD_URI='https://pm.puppet.com/cgi-bin/download.cgi?arch=amd64&dist=ubuntu&rel=18.04&ver=latest'}


function hello() {
    msg='Hello from the PE Master bootstrap script!'
    logger $msg
    echo $msg
}


function check_deps() {
    command -v hocon && command -v facter
    if [ "0" -ne "$?" ]; then
	apt-get update
	apt-get install -y ruby-hocon facter
    fi
}


function pe_install() {
    wget -q -c -O /tmp/pe.tar.gz "${PE_DOWNLOAD_URI}"
    mkdir -p /tmp/pe
    tar xvf /tmp/pe.tar.gz -C /tmp/pe --strip-components 1

    public_hostname="$(facter ec2_metadata.public-hostname)"

    hocon -f /tmp/pe/conf.d/pe.conf set console_admin_password vault-puppet-demo

    # There are a number of settings which have to be adjust to ensure proper operation though
    # an AWS loadbalancer.
    hocon -f /tmp/pe/conf.d/pe.conf set pe_install\"::\"master_pool_address "https\"://\"${public_hostname}\":\"8140"
    hocon -f /tmp/pe/conf.d/pe.conf set pe_install\"::\"puppet_master_dnsaltnames "[ \"${public_hostname}\" ]"
    hocon -f /tmp/pe/conf.d/pe.conf set pe_repo\"::\"master "https\"://\"${public_hostname}\":\"8140"
    hocon -f /tmp/pe/conf.d/pe.conf set puppet_enterprise\"::\"profile\"::\"agent\"::\"master_uris "[ \"https://${public_hostname}:8140\" ]"
    hocon -f /tmp/pe/conf.d/pe.conf set puppet_enterprise\"::\"profile\"::\"agent\"::\"pcp_broker_list "[ \"https://${public_hostname}:8140\" ]"

    /tmp/pe/puppet-enterprise-installer -c /tmp/pe/conf.d/pe.conf -y

    sleep 10
    while true; do
	set +e
	puppet agent -t
	if [ "$?" -eq "0" ]; then
	    set -e; break
	fi
    done
}


function papertrail_install() {
    echo 'Installing Papertrail agent...'
    wget -O /tmp/papertrail_setup.sh --header="X-Papertrail-Token: ${papertrail_token}" https://papertrailapp.com/destinations/10987402/setup.sh
    chmod +x /tmp/papertrail_setup.sh
    /tmp/papertrail_setup.sh -q
    rm /tmp/papertrail_setup.sh
}


function goodbye() {
    msg = 'PE Master bootstrap script finished.'
    logger $msg
    echo $msg
}


main() {
    hello
    check_deps

    set -eux
    papertrail_install

    set -x
    pe_install
    goodbye
    exit 0
}


main
