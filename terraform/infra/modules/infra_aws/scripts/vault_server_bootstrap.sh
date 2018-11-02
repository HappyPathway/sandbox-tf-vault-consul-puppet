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
	set +e
	sleep 3
	http "https://${PUPPET_MASTER_ADDR}:8140/packages/current/install.bash" > /dev/null 2>&1
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
