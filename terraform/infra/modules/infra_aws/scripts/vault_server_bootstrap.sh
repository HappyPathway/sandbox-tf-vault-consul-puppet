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


# function vault_server_config() {
#     bind_addr="$(facter ipaddress)"
#     advertise_addr="$(http -b http://169.254.169.254/latest/meta-data/public-ipv4)"

#     mkdir -p /var/lib/vault
#     chown -R vault.vault /var/lib/vault
#     chgrp -R 770 /var/lib/vault

#     tee /etc/vault.d/z-vault.hcl <<EOF
# server=true
# log_level="info"
# client_addr="0.0.0.0"
# ui=true
# bind_addr="${bind_addr}"
# advertise_addr="${advertise_addr}"
# data_dir="/var/lib/vault"
# EOF

#     vault validate /etc/vault.d
#     service vault restart
# }

function goodbye() {
    msg='Vault Server bootstrap script finished.'
    logger $msg
    echo $msg
}


function puppet_agent_install() {
    echo "Installing Puppet agent..."
    curl -k "https://${PUPPET_MASTER_ADDR}:8140/packages/current/install.bash" | bash
}


main() {
    set -eu
    papertrail_install

    set -eux
    hello
    check_deps

    set -x
    #    vault_server_config
    pupppet_agent_install
    goodbye
    exit 0
}


main
