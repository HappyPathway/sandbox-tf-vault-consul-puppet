PAPERTRAIL_TOKEN="${papertrail_token}"


# require the following environment variables:
#   - CONSUL_SERVER : IP address or hostname of a Consul server
#   - PUPPET_ENTERPRISE_MASTER : IP address or hostname of a Puppet Enterprise master for download of Agent and classification.
: ${CONSUL_DOWNLOAD_URI='https://releases.hashicorp.com/consul/1.3.0/consul_1.3.0_linux_amd64.zip'}
: ${CONSUL_TEMPLATE_DOWNLOAD_URI='https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.zip'}


function hello() {
    msg='Hello from the Consul client bootstrap script!'
    logger $msg
    echo $msg

    set -u

    echo "Consul Servers specified via CONSUL_SERVER environment variable: ${CONSUL_SERVER}"
    echo "Puppet Enterprise Master specified via PUPPET_ENTERPRISE_MASTER environment variable: ${PUPPET_ENTERPRISE_MASTER}"
}


function check_deps() {
    echo "Checking for required software..."
    command -v zip && command -v daemonize && command -v httpie && command -v curl
    if [ "0" -ne "$?" ]; then
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true
	apt-get update
	apt-get install -y zip daemonize httpie curl
    fi
}


function consul_client_install() {
   echo "Downloading and installing Consul agent..."
   wget -q -c -O /tmp/consul.zip "${CONSUL_DOWNLOAD_URI}"
   unzip -o /tmp/consul.zip -d /usr/local/bin/

   mkdir -p /etc/consul.d /var/lib/consul



   consul_bind_addr=$(hostname -I | cut -d ' ' -f2)

   cat > /etc/consul.d/consul.hcl <<CONSULCONFIG
data_dir="/var/lib/consul"
retry_join=["${CONSUL_SERVER}"]
bind_addr="${consul_bind_addr}"
CONSULCONFIG

   cat /etc/consul.d/consul.hcl

   pkill -TERM consul && sleep 3 && pkill -9 consul
   consul validate /etc/consul.d
   daemonize /usr/local/bin/consul agent -config-dir /etc/consul.d -syslog
}


function consul_template_install() {
    echo "Downloading and installing consul-template..."
    wget -q -c -O /tmp/consul-template.zip "${CONSUL_TEMPLATE_DOWNLOAD_URI}"
    unzip -o /tmp/consul-template.zip -d /usr/local/bin/

    mkdir -p /etc/consul-template.d
    cat > /etc/consul-template.d/smokecheck.tpl <<CONSUL_TEMPLATE_CONF
CONSUL_TEMPLATE_CONF

    cat /etc/consul-template.d/smokecheck.tpl

    pkill -TERM consul-template && sleep 3 && pkill -9 consul-template
    consul-template -config /etc/consul-template.d -dry -once
    daemonize /usr/local/bin/consul-template -config /etc/consul-template.d -syslog
}


function puppet_agent_install() {
    echo "Downloading and installing Puppet Agent..."
    curl -k "https://${PUPPET_ENTERPRISE_MASTER}:8140/packages/current/install.bash" | bash

    sleep 10
    while true; do
	set +e
	puppet agent -t
	if [ "$?" -eq "0" ]; then
	    set -e ; break
	fi
    done
}


function goodbye() {
    msg="Consul Agent bootstrap finished."
    logger $msg
    echo $msg
}


function papertrail_install() {
    echo "Installing Papertrail agent..."
    wget -O /tmp/papertrail_setup.sh --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" https://papertrailapp.com/destinations/10987402/setup.sh
    chmod +x /tmp/papertrail_setup.sh
    /tmp/papertrail_setup.sh -q
    rm /tmp/papertrail_setup.sh
}


function main() {
    set -eu
    papertrail_install

    set -eux
    hello
    check_deps

    consul_client_install
    consul_template_install
    puppet_agent_install

    goodbye
    exit 0
}


main
