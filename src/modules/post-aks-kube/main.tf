resource "null_resource" "kubenet_udr" {

  provisioner "local-exec" {
    command = "./rtnsg-fix.sh"

    environment {
      AKS_VNET_RG      = var.AKS_RG_NAME
      AKS_VNET_NAME    = var.AKS_VNET_NAME
      AKS_SUBNET_NAME  = var.AKS_SUBNET_NAME
      AZFW_INT_IP      = var.AZFW_PRIVIP
      AZ_CLIENT_ID     = var.TF_CLIENT_SECRET
      AZ_CLIENT_SECRET = var.TF_CLIENT_ID
      AZ_TENANT_ID     = var.TF_TENANT_ID
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "./rtnsg-rm.sh"

    environment {
      AKS_VNET_RG      = var.AKS_RG_NAME
      AKS_VNET_NAME    = var.AKS_VNET_NAME
      AKS_SUBNET_NAME  = var.AKS_SUBNET_NAME
      AZ_CLIENT_ID     = var.TF_CLIENT_SECRET
      AZ_CLIENT_SECRET = var.TF_CLIENT_ID
      AZ_TENANT_ID     = var.TF_TENANT_ID
    }
  }
}

data "dns_a_record_set" "apiIP" {
  host = var.AKS_API_FQDN
}

resource "azurerm_firewall_network_rule_collection" "netruleazfw" {
  name                = "AzureFirewallNetCollection-API"
  azure_firewall_name = var.AZFW_NAME
  resource_group_name = var.AZFW_RG_NAME
  priority            = 201
  action              = "Allow"

  depends_on = [
    "data.dns_a_record_set.apiIP"
  ]
  rule {
    name = "AllowAPIServer"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "443"
    ]
    destination_addresses = [
      "${join(",", data.dns_a_record_set.apiIP.addrs)}"
    ]
    protocols = [
      "TCP"
    ]
  }
}

