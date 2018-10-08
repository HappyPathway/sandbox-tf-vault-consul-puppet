PAPERTRAIL_TOKEN="${papertrail_token}"
PUPPET_MASTER_ADDR="${puppet_master_addr}"


function hello() {
    msg='Hello from the Vault Server bootstrap script!'
    logger $msg
    echo $msg
}


function check_deps() {
    echo "Checking for required software..."
    command -v facter && command -v httpie && command -v curl
    if [ "0" -ne "$?" ]; then
	yum install -y facter httpie curl dnsmasq dnsmasq-utils bmon mosh
    fi
}


function papertrail_install() {
    echo "Installing Papertrail agent..."
    wget -O /tmp/papertrail_setup.sh --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" https://papertrailapp.com/destinations/10987402/setup.sh
    chmod +x /tmp/papertrail_setup.sh
    /tmp/papertrail_setup.sh -q
    rm /tmp/papertrail_setup.sh
}


function puppet_agent_install() {
    echo "Installing Puppet agent..."

    while true; do
	echo "Checking for availability of Puppet pluginsync bundle..."
	set +e
	sleep 3
	http --check-status --verify no "https://${PUPPET_MASTER_ADDR}:8140/packages/bulk_pluginsync.tar.gz" > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
	    break
	fi
    done

    while true; do
	echo "Checking Puppet server for availablity of Puppet Agent install script..."
	set +e
	sleep 3

	http --check-status --verify no "https://${PUPPET_MASTER_ADDR}:8140/packages/current/install.bash" > /tmp/install.bash
	if [ "$?" -eq "0" ]; then
	    break
	fi
    done

    set -e
    echo "Exeucting the Puppet Agent installer..."
    chmod +x /tmp/install.bash
    /tmp/install.bash

    while true; do
	echo "Running Puppet Agent until we converge..."
	set +e
	sleep 3
	puppet agent -t --waitforcert 10 --detailed-exitcodes
	if [ "$?" -eq "0" ]; then
	    break
	fi
    done

    set -e
}


function goodbye() {
    msg='Vault Server bootstrap script finished.'
    logger $msg
    echo $msg
}


main() {
    set -eu
    papertrail_install

    set -eux
    hello
    check_deps

    set -x
    #    vault_server_config
    puppet_agent_install
    goodbye
    exit 0
}


main
