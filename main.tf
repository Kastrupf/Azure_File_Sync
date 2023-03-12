# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg-base" {
  name     = "rg-filesync"
  location = "UK South"
}

# Create a virtual network LOCAL - ONPREMISES
resource "azurerm_virtual_network" "vnet-local" {
  name                = "vnet-local"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = azurerm_resource_group.rg-base.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub-local" {
  name                 = "sub-local"
  resource_group_name  = azurerm_resource_group.rg-base.name
  virtual_network_name = azurerm_virtual_network.vnet-local.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create NSG Local
resource "azurerm_network_security_group" "nsg-local" {
  name                = "nsg-local"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.0.0/24"
  }
}

# Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "nsg-local-ass" {
  subnet_id                 = azurerm_subnet.sub-local.id
  network_security_group_id = azurerm_network_security_group.nsg-local.id
}

# Create a virtual network AZURE
resource "azurerm_virtual_network" "vnet-azure" {
  name                = "vnet-azure"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = "France Central"
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "sub-local-azure" {
  name                 = "sub-azure"
  resource_group_name  = azurerm_resource_group.rg-base.name
  virtual_network_name = azurerm_virtual_network.vnet-azure.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg-base.name
  virtual_network_name = azurerm_virtual_network.vnet-azure.name
  address_prefixes     = ["192.168.250.0/24"]
}

# Create NSG Azure
resource "azurerm_network_security_group" "nsg-azure" {
  name                = "nsg-azure"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "192.168.0.0/24"
  }
}

# Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "nsg-azure-ass" {
  subnet_id                 = azurerm_subnet.sub-local-azure.id
  network_security_group_id = azurerm_network_security_group.nsg-azure.id
}

# Create public IPs - VM-AD
resource "azurerm_public_ip" "pip-vm-ad" {
  name                = "pip-vm-ad"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name
  allocation_method   = "Dynamic"
}

# Create NIC - VM-AD
resource "azurerm_network_interface" "nic-ad" {
  name                = "nic-ad"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-local.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-ad.id
  }
}

# Create VM-AD
resource "azurerm_windows_virtual_machine" "vm-ad" {
  name                = "vm-ad"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = azurerm_resource_group.rg-base.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic-ad.id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# Create public IPs - VM-FS
resource "azurerm_public_ip" "pip-vm-fs" {
  name                = "pip-vm-fs"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name
  allocation_method   = "Dynamic"
}

# Create NIC - VM-FS
resource "azurerm_network_interface" "nic-fs" {
  name                = "nic-fs"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-local.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-fs.id
  }
}

# Create VM-FS
resource "azurerm_windows_virtual_machine" "vm-fs" {
  name                = "vm-fs"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = azurerm_resource_group.rg-base.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic-fs.id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# Create Data Disk - VM-FS
resource "azurerm_managed_disk" "disk-data" {
  name                 = "disk-data"
  location             = azurerm_resource_group.rg-base.location
  resource_group_name  = azurerm_resource_group.rg-base.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

# Attach Data Disk - VM-FS
resource "azurerm_virtual_machine_data_disk_attachment" "disk-att" {
  managed_disk_id    = azurerm_managed_disk.disk-data.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm-fs.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Create public IPs - VM-FW
resource "azurerm_public_ip" "pip-vm-fw" {
  name                = "pip-vm-fw"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name
  allocation_method   = "Static"
}

# Create NIC - VM-FW
resource "azurerm_network_interface" "nic-fw" {
  name                = "nic-fw"
  location            = azurerm_resource_group.rg-base.location
  resource_group_name = azurerm_resource_group.rg-base.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-local.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-fw.id
  }
}

# Create VM-FW
resource "azurerm_windows_virtual_machine" "vm-fw" {
  name                = "vm-fw"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = azurerm_resource_group.rg-base.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic-fw.id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

# Create public IPs - VM-DNS
resource "azurerm_public_ip" "pip-vm-dns" {
  name                = "pip-vm-dns"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name
  allocation_method   = "Dynamic"
}

# Create NIC - VM-DNS
resource "azurerm_network_interface" "nic-dns" {
  name                = "nic-dns"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-local-azure.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-vm-dns.id
  }
}

# Create VM-DNS
resource "azurerm_windows_virtual_machine" "vm-dns" {
  name                = "vm-dns"
  resource_group_name = azurerm_resource_group.rg-base.name
  location            = "France Central"
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic-dns.id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

#CONFIGURE VPN S2S
resource "azurerm_local_network_gateway" "onpremise" {
  name                = "lng-local"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name
  gateway_address     = azurerm_public_ip.pip-vm-fw.ip_address
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "pip-vpn" {
  name                = "pip-vpn"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vng-azure" {
  name                = "vng-azure"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.pip-vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "conect-onpremise" {
  name                = "vpn-local"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg-base.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-azure.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id
  shared_key = "partiunuvem@2023"
  depends_on = [azurerm_public_ip.pip-vm-fw]
}

# Configure Azure Table
resource "azurerm_route_table" "rt-local" {
  name                          = "rt-local"
  location                      = azurerm_resource_group.rg-base.location
  resource_group_name           = azurerm_resource_group.rg-base.name
  disable_bgp_route_propagation = false

  route {
    name           = "route-azure"
    address_prefix = "192.168.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic-fw.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "route-asso" {
  subnet_id      = azurerm_subnet.sub-local.id
  route_table_id = azurerm_route_table.rt-local.id
}