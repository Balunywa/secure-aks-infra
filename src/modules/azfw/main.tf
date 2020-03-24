resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = "${join(",", var.DEPENDENCY)}"
  }
}

resource "azurerm_public_ip" "azfwpip" {
  depends_on = [
    null_resource.dependency_getter,
  ]
  name                = "azfwpip"
  location            = var.REGION
  resource_group_name = var.HUB_RG_NAME
  allocation_method   = "Static"
  sku                 = "Standard"

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

output "azfw_pip" {
  value = azurerm_public_ip.azfwpip.ip_address
}

resource "azurerm_firewall" "hubazfw" {
  depends_on = [
    null_resource.dependency_getter,
  ]
  name                = "hubazfw-${var.REGION}"
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

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.HUB_SUBNET_ID
    public_ip_address_id = azurerm_public_ip.azfwpip.id
  }
}

resource "azurerm_firewall_application_rule_collection" "appruleazfw" {
  depends_on = [
    null_resource.dependency_getter,
  ]
  name                = "AzureFirewallAppCollection"
  azure_firewall_name = azurerm_firewall.hubazfw.name
  resource_group_name = var.HUB_RG_NAME
  priority            = 100
  action              = "Allow"
  rule {
    name = "hcp_rules"
    source_addresses = [
      "*",
    ]
    target_fqdns = [
      "*.hcp.${var.REGION}.azmk8s.io", #This address is the API server endpoint. Replace <location> with the region where your AKS cluster is deployed.
      "*.tun.${var.REGION}.azmk8s.io", #This address is the API server endpoint. Replace <location> with the region where your AKS cluster is deployed.
      "mcr.microsoft.com",             #This address is required to access images in Microsoft Container Registry (MCR).
      "*.data.mcr.microsoft.com",      #This address is required for MCR storage backed by the Azure content delivery network (CDN).
      "*.cdn.mscr.io",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net",
      "login.microsoftonline.com",
      "management.azure.com", #This address is required for Kubernetes GET/PUT operations.
    ] #This address is required to pull required container images for the tunnel front.

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "dockerReg_rules"
    source_addresses = [
      "*",
    ]
    target_fqdns = [
      var.DOCKER_REGISTRY, #FQDN for Private registry
      "*.cloudflare.docker.com",
    ] #FQDN used by docker.io for CDN of images.

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "azmon_support_rules"
    source_addresses = [
      "*",
    ]
    target_fqdns = [
      "dc.services.visualstudio.com", #This address is used for correct operation of Azure Policy (currently in preview in AKS).
      "*.ods.opinsights.azure.com",                        #This address is used for correct driver installation and operation on GPU-based nodes.
      "*.oms.opinsights.azure.com",
      "*.microsoftonline.com",
      "*.monitoring.azure.com",
    ] #This address is used for correct driver installation and operation on GPU-based nodes.

    protocol {
      port = "443"
      type = "Https"
    }
  }
  rule {
    name = "aks_support_rules2"
    source_addresses = [
      "*",
    ]
    target_fqdns = [
      "security.ubuntu.com", #This address lets the Linux cluster nodes download the required security patches and updates.
      "azure.archive.ubuntu.com",
      "changelogs.ubuntu.com"
    ] #This address is required to install Snap packages on Linux nodes. Uses both port 80 and 443

    protocol {
      port = "80"
      type = "Http"
    }
  }
  # rule {
  #   name = "gpu_support_rules"
  #   source_addresses = [
  #     "*",
  #   ]
  #   target_fqdns = [
  #                      #This address is the Microsoft packages repository used for cached apt-get operations.
  #     "nvidia.github.io",                        #This address is used for correct driver installation and operation on GPU-based nodes.
  #     "us.download.nvidia.com",
  #     "apt.dockerproject.org",
  #   ] #This address is used for correct driver installation and operation on GPU-based nodes.

  #   protocol {
  #     port = "443"
  #     type = "Https"
  #   }
  # }
}

resource "azurerm_firewall_network_rule_collection" "netruleazfw-ports" {
  depends_on = [
    null_resource.dependency_getter,
  ]
  name                = "AzureFirewallNetCollection-ports"
  azure_firewall_name = azurerm_firewall.hubazfw.name
  resource_group_name = var.HUB_RG_NAME
  priority            = 200
  action              = "Allow"
  rule {
    name = "AllowTCPOutbound"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "9000",
      "22"
    ] #TCP Port used by TunnelFront

    destination_addresses = [
      "*",
    ]
    protocols = [
      "TCP",
    ]
  }
  rule {
    name = "AllowUDPOutbound"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "53",  #Port used for DNS
      "123", #UDP port used for time services
      "1194" #UDP for Tunnel
    ]

    destination_addresses = [
      "*",
    ]
    protocols = [
      "UDP",
    ]
  }
}

output "azfw_name" {
  value = azurerm_firewall.hubazfw.name
}

output "azfw_PrivIP" {
  value = azurerm_firewall.hubazfw.ip_configuration.0.private_ip_address
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    azurerm_firewall_network_rule_collection.netruleazfw-ports,
    azurerm_firewall_application_rule_collection.appruleazfw
  ]
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}