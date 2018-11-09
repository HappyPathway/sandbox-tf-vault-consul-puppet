PAPERTRAIL_TOKEN="${papertrail_token}"
PUPPET_MASTER_ADDR="${puppet_master_addr}"

function hello() {
    msg='Hello from the Puppet Agent bootstrap script!'
    logger $msg
    echo $msg
}


function check_deps() {
    echo "Checking for required software..."
    command -v facter && command -v httpie && command -v curl
    if [ "0" -ne "$?" ]; then
	apt-get update
	apt-get install -y facter httpie curl dnsmasq bmon mosh
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
	set +e
	sleep 3
	http --check-status --verify no "https://${PUPPET_MASTER_ADDR}:8140/packages/bulk_pluginsync.tar.gz" > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
	    break
	fi
    done
    set -e

    curl \
	-k \
	--retry 100 \
	--max-time 10 \
	--retry-delay 0 \
	--retry-max-time 600 \
	"https://${PUPPET_MASTER_ADDR}:8140/packages/current/install.bash" | bash

    yum remove facter -y
    pkill -HUP puppet
}


function goodbye() {
    msg='Puppet Agent bootstrap script finished.'
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
    puppet_agent_install
    goodbye
    exit 0
}


main
