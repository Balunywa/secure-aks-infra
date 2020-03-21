provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "aksvnet" {
  name                = var.AKS_VNET_NAME
  location            = var.REGION
  address_space       = var.AKS_VNET_CIDR
  resource_group_name = var.AKS_RG_NAME
  dns_servers         = var.DNS_SERVERS

  tags = {
    costcenter           = var.COST_CENTER
    deploymenttype       = var.DEPLOY_TYPE
    environmentinfo      = var.ENVIRONMENT
    notificationdistlist = var.NOTIFY_LIST
    ownerinfo            = var.OWNER_INFO
    platform             = var.PLATFORM
    sponsorinfo          = var.SPONSOR_INFO
  }
}

resource "azurerm_subnet" "akssubnet" {
  for_each             = var.AKS_SUBNET_NAMES
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = var.AKS_RG_NAME
  address_prefix       = each.value
}

output "subnet_id" {
  value = [
    for instance in azurerm_subnet.akssubnet :
    instance.id
  ]
}