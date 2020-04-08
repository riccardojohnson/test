provider "azurerm" {
   version = "~>2.00"
   #features {}
   subscription_id = var.subscription_id
   tenant_id = var.tenant_id
   client_id = var.client_id
   client_secret = var.client_secret
}

resource "azurerm_resource_group" "rgrjtest" {
 name     = "test-rg-rj"
 location = "uksouth"
}

resource "azurerm_virtual_network" "vnrjtest" {
 name                = "acctvn"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.rgrjtest.location
 resource_group_name = azurerm_resource_group.rgrjtest.name
}

resource "azurerm_subnet" "snrjtest" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.rgrjtest.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "piprjtest" {
 name                         = "publicIPForLB"
 location                     = azurerm_resource_group.rgrjtest.location
 resource_group_name          = azurerm_resource_group.rgrjtest.name
 allocation_method            = "Static"
}

resource "azurerm_lb" "lbrjtest" {
 name                = "loadBalancer"
 location            = azurerm_resource_group.rgrjtest.location
 resource_group_name = azurerm_resource_group.rgrjtest.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.test.id
 }
}

resource "azurerm_lb_backend_address_pool" "lbbeaprjtest" {
 resource_group_name = azurerm_resource_group.rgrjtest.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "nirjtest" {
 count               = 2
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.rgrjtest.location
 resource_group_name = azurerm_resource_group.rgrjtest.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "mdrjtest" {
 count                = 2
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.rgrjtest.location
 resource_group_name  = azurerm_resource_group.rgrjtest.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "asrjavset" {
 name                         = "avset"
 location                     = azurerm_resource_group.rgrjtest.location
 resource_group_name          = azurerm_resource_group.rgrjtest.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
}

resource "azurerm_virtual_machine" "vmrjtest" {
 count                 = 2
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.rgrjtest.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.rgrjtest.name
 network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.test.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "srvadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "staging"
 }
}