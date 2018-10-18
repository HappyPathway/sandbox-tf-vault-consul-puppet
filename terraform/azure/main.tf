provider "azurerm" {}

resource "azurerm_resource_group" "resource_gp" {
  name     = "${var.app_name}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.app_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource_gp.name}"
}

resource "azurerm_subnet" "main" {
  name                 = "testsubnet"
  resource_group_name  = "${azurerm_resource_group.resource_gp.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "app_vm_public_ip" {
  name                         = "vaultpuppetappbootdiags"
  resource_group_name          = "${azurerm_resource_group.resource_gp.name}"
  location                     = "${var.location}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "Vault Puppet demo"
  }
}

resource "azurerm_network_interface" "netint" {
  name                = "networkinterface-vault-puppet"
  location            = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name = "${azurerm_resource_group.resource_gp.name}"

  ip_configuration {
    name                          = "ipconfig-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation  = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.app_vm_public_ip.id}"
  }

  tags {
    environment = "Vault Puppet demo"
  }
}



resource "azurerm_storage_account" "app_vm_boot_diagnostics" {
  name                     = "vaultpuppetappbootdiags"
  resource_group_name      = "${azurerm_resource_group.resource_gp.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "Puppet Vault demo"
  }
}

data "template_file" "azure_custom_data" {
  template = "${file("${path.module}/../templates/consul_client_bootstrap.sh.tpl")}"

  vars {
    papertrail_token = "${var.papertrail_token}"
    logic            = "${file("${path.module}/../scripts/consul_client_bootstrap.sh")}"
  }
}

resource "azurerm_virtual_machine" "app_vm" {
  name                          = "${var.app_name}-vms-${count.index + 1}"
  location                      = "${azurerm_resource_group.resource_gp.location}"
  resource_group_name           = "${azurerm_resource_group.resource_gp.name}"
  network_interface_ids         = ["${element(azurerm_network_interface.netint.*.id, count.index)}"]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "azure-${var.app_name}-${count.index + 1}"
    admin_username = "ubuntu"
    admin_password = "vault-puppet-demo-1234!"
    custom_data    = "${data.template_file.azure_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.app_vm_boot_diagnostics.primary_blob_endpoint}"
  }

  tags {
    enviroment = "Vault Puppet demo"
  }
}
