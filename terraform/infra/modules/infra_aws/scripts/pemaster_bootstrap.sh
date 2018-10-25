PAPERTRAIL_TOKEN="${papertrail_token}"

: ${PE_DOWNLOAD_URI='https://pm.puppet.com/cgi-bin/download.cgi?arch=amd64&dist=ubuntu&rel=18.04&ver=latest'}
: ${CONSUL_DOWNLOAD_URI='https://releases.hashicorp.com/consul/1.3.0/consul_1.3.0_linux_amd64.zip'}
: ${CONSUL_TEMPLATE_DOWNLOAD_URI='https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.zip'}

function hello() {
    msg='Hello from the PE Master bootstrap script!'
    logger $msg
    echo $msg
}


function check_deps() {
    echo "Checking for required software..."
    command -v hocon && command -v facter && command -v httpie && command -v curl
    if [ "0" -ne "$?" ]; then
	apt-get update
	apt-get install -y ruby-hocon facter daemonize httpie curl dnsmasq-base dnsmasq-utils
    fi
}


function pe_install() {
    echo "Downloading and install PE master..."
    wget -q -c -O /tmp/pe.tar.gz "${PE_DOWNLOAD_URI}"
    mkdir -p /tmp/pe
    tar xvf /tmp/pe.tar.gz -C /tmp/pe --strip-components 1

    public_hostname="$(facter ec2_metadata.public-hostname)"

    hocon -f /tmp/pe/conf.d/pe.conf set console_admin_password vault-puppet-demo

    # There are a number of settings which have to be adjust to ensure proper operation though
    # an AWS loadbalancer.
    hocon -f /tmp/pe/conf.d/pe.conf set pe_install\"::\"master_pool_address "${public_hostname}"
    hocon -f /tmp/pe/conf.d/pe.conf set pe_install\"::\"puppet_master_dnsaltnames "[ \"${public_hostname}\", \"puppet.node.dc1.consul\" ]"
    hocon -f /tmp/pe/conf.d/pe.conf set pe_repo\"::\"master "${public_hostname}"
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
    echo "Installing Papertrail agent..."
    wget -O /tmp/papertrail_setup.sh --header="X-Papertrail-Token: ${PAPERTRAIL_TOKEN}" https://papertrailapp.com/destinations/10987402/setup.sh
    chmod +x /tmp/papertrail_setup.sh
    /tmp/papertrail_setup.sh -q
    rm /tmp/papertrail_setup.sh
}


function consul_agent_install() {
   echo "Downloading and installing Consul agent..."
   wget -q -c -O /tmp/consul.zip "${CONSUL_DOWNLOAD_URI}"
   unzip -o /tmp/consul.zip -d /usr/local/bin/

   mkdir -p /etc/consul.d /var/lib/consul

   consul_bind_addr=$(hostname -I | cut -d ' ' -f2)
   public_hostname="$(facter ec2_metadata.public-hostname)"

   cat > /etc/consul.d/consul.hcl <<CONSULCONFIG
data_dir="/var/lib/consul"
retry_join=["${consul_server}"]
bind_addr="${consul_bind_addr}"
advertise_addr="${public_hostname}"
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


function dnsmasq_configure() {
    cat > /etc/dnsmasq.d/10-consul <<EOF
server=/consul/127.0.0.1:8600
EOF
    pkill -HUP dnsmasq
}


function goodbye() {
    msg="PE Master bootstrap script finished."
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
    consul_agent_install
    consul_template_install
    dnsmasq_configure
    pe_install
    goodbye
    exit 0
}


main
