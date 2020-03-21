resource "azurerm_route_table" "vdmzudr" {
  name                = "${var.CLUSTER_ID}routetable"
  location            = var.REGION
  resource_group_name = var.AKS_RG_NAME


  route {
    name                   = "vDMZ"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.AZFW_PRIV_IP
  }
}

resource "azurerm_subnet_route_table_association" "vdmzudr" {
  subnet_id      = var.AKS_SUBNET_ID
  route_table_id = azurerm_route_table.vdmzudr.id
}

resource "azurerm_firewall_network_rule_collection" "netruleazfw-temp" {
  name                = "AzureFirewallNetCollection-API-TEMP"
  azure_firewall_name = var.AZFW_NAME
  resource_group_name = var.HUB_RG_NAME
  priority            = 210
  action              = "Allow"

  rule {
    name = "AllowTempAPIAccess"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "443"
    ]
    destination_addresses = [
      "AzureCloud.${var.REGION}"
    ]
    protocols = [
      "TCP"
    ]
  }
}