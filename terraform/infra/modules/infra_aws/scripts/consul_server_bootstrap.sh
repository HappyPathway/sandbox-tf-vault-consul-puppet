PAPERTRAIL_TOKEN="${papertrail_token}"

function hello() {
    msg='Hello from the Consul Server bootstrap script!'
    logger $msg
    echo $msg
}


function check_deps() {
    echo "Checking for required software..."
    command -v facter && command -v httpie && command -v curl
    if [ "0" -ne "$?" ]; then
	yum install -y facter httpie curl dnsmasq-base dnsmasq-utils bmon mosh
    fi
}


function papertrail_install() {
    echo "Installing Papertrail agent..."
    wget -O /tmp/papertrail_setup.sh --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" https://papertrailapp.com/destinations/10987402/setup.sh
    chmod +x /tmp/papertrail_setup.sh
    /tmp/papertrail_setup.sh -q
    rm /tmp/papertrail_setup.sh
}


function dnsmasq_configure() {
    tee /etc/dnsmasq.d/10-consul <<EOF
server=/consul/127.0.0.1:8600
EOF
    pkill -HUP dnsmasq
}


function consul_server_config() {
    bind_addr="$(facter ipaddress)"
    advertise_addr="$(http -b http://169.254.169.254/latest/meta-data/public-ipv4)"

    tee /etc/consul.d/z-consul.hcl <<EOF
server=true
log_level="info"
client_addr="0.0.0.0"
ui=true
bind_addr="${bind_addr}"
advertise_addr="${advertise_addr}"
data_dir="/var/consul"
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
    dnsmasq_configure
    consul_server_config
    goodbye
    exit 0
}


main
