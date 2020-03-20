resource "azurerm_virtual_network" "hubvnet" {
  name                = "hubvnet"
  address_space       = var.HUB_VNET_ADDR_SPACE
  location            = var.REGION
  resource_group_name = var.HUB_RG_NAME

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

resource "azurerm_subnet" "azfwsubnet" {
  for_each             = var.SUBNET_NAMES
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  resource_group_name  = var.HUB_RG_NAME
  address_prefix       = each.key
}

output "subnet_id" {
  value = azurerm_subnet.azfwsubnet.id
}