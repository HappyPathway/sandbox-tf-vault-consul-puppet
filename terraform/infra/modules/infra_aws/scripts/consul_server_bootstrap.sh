PAPERTRAIL_TOKEN="${papertrail_token}"
PUPPET_MASTER_ADDR="${puppet_master_addr}"


function hello() {
    msg='Hello from the Consul Server bootstrap script!'
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
	http --verify no "https://${PUPPET_MASTER_ADDR}:8140/packages/current/install.bash" > /dev/null 2>&1
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

function consul_server_config() {
    bind_addr="$(facter ipaddress)"
    advertise_addr="$(http -b http://169.254.169.254/latest/meta-data/public-ipv4)"

    mkdir -p /var/lib/consul
    chown -R consul.consul /var/lib/consul
    chgrp -R 770 /var/lib/consul

    tee /etc/consul.d/z-consul.hcl <<EOF
server=true
log_level="info"
client_addr="0.0.0.0"
ui=true
bind_addr="${bind_addr}"
advertise_addr="${advertise_addr}"
data_dir="/var/lib/consul"
EOF

    consul validate /etc/consul.d
    service consul restart
}

function goodbye() {
    msg='Consul Server bootstrap script finished.'
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
