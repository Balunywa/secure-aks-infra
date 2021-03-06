provider "azurerm" {
  features {}

  subscription_id = var.SUB_ID
  client_id       = var.TFUSER_CLIENT_ID
  client_secret   = var.TFUSER_CLIENT_SECRET
  tenant_id       = var.TENANT_ID
}

resource "azurerm_resource_group" "hubrg" {
  name     = "rg-${var.CLUSTER_ID}-hub"
  location = var.REGION

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

module "fw-net" {
  source              = "../modules/fw-net"
  HUB_RG_NAME         = azurerm_resource_group.hubrg.name
  CLUSTER_ID          = var.CLUSTER_ID
  COST_CENTER         = var.COST_CENTER
  DEPLOY_TYPE         = var.DEPLOY_TYPE
  ENVIRONMENT         = var.ENVIRONMENT
  NOTIFY_LIST         = var.NOTIFY_LIST
  OWNER_INFO          = var.OWNER_INFO
  PLATFORM            = var.PLATFORM
  SPONSOR_INFO        = var.SPONSOR_INFO
  REGION              = var.REGION
  HUB_VNET_ADDR_SPACE = var.HUB_VNET_ADDR_SPACE
  HUB_SUBNET_NAMES    = var.HUB_SUBNET_NAMES
  DEPENDENCY          = [azurerm_resource_group.hubrg.name]
}

module "azfw" {
  source          = "../modules/azfw"
  HUB_RG_NAME     = azurerm_resource_group.hubrg.name
  CLUSTER_ID      = var.CLUSTER_ID
  COST_CENTER     = var.COST_CENTER
  DEPLOY_TYPE     = var.DEPLOY_TYPE
  ENVIRONMENT     = var.ENVIRONMENT
  NOTIFY_LIST     = var.NOTIFY_LIST
  OWNER_INFO      = var.OWNER_INFO
  PLATFORM        = var.PLATFORM
  SPONSOR_INFO    = var.SPONSOR_INFO
  REGION          = var.REGION
  HUB_SUBNET_ID   = module.fw-net.subnet_id[0]
  DOCKER_REGISTRY = var.DOCKER_REGISTRY
  DEPENDENCY      = [module.fw-net.depended_on]
}

resource "azurerm_resource_group" "aksrg" {
  name     = "rg-${var.CLUSTER_ID}"
  location = var.REGION
  depends_on = [
    module.azfw.azfw_name
  ]

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

module "aks-net" {
  source = "../modules/aks-net"

  AKS_RG_NAME      = azurerm_resource_group.aksrg.name
  CLUSTER_ID       = var.CLUSTER_ID
  COST_CENTER      = var.COST_CENTER
  DEPLOY_TYPE      = var.DEPLOY_TYPE
  ENVIRONMENT      = var.ENVIRONMENT
  NOTIFY_LIST      = var.NOTIFY_LIST
  OWNER_INFO       = var.OWNER_INFO
  PLATFORM         = var.PLATFORM
  SPONSOR_INFO     = var.SPONSOR_INFO
  REGION           = var.REGION
  AKS_VNET_NAME    = var.AKS_VNET_NAME
  AKS_VNET_CIDR    = var.AKS_VNET_CIDR
  AKS_SUBNET_NAMES = var.AKS_SUBNET_NAMES
  DNS_SERVERS      = var.DNS_SERVERS
  DEPENDENCY       = [azurerm_resource_group.aksrg.name]
}

module "vnet-peer" {
  source = "../modules/vnet-peer"

  HUB_RG_NAME   = azurerm_resource_group.hubrg.name
  HUB_VNET_NAME = module.fw-net.hub_vnet_name
  AKS_VNET_ID   = module.aks-net.aks_vnet_id
  AKS_RG_NAME   = azurerm_resource_group.aksrg.name
  AKS_VNET_NAME = module.aks-net.aks_vnet_name
  HUB_VNET_ID   = module.fw-net.hub_vnet_id
  CLUSTER_ID       = var.CLUSTER_ID
  DEPENDENCY    = [module.aks-net.depended_on, module.fw-net.depended_on]
}

module "pre-aks-kube" {
  source = "../modules/pre-aks-kube"

  AKS_RG_NAME   = azurerm_resource_group.aksrg.name
  HUB_RG_NAME   = azurerm_resource_group.hubrg.name
  AZFW_NAME     = module.azfw.azfw_name
  AKS_SUBNET_ID = module.aks-net.subnet_id[0]
  AZFW_PRIV_IP  = module.azfw.azfw_PrivIP
  CLUSTER_ID    = var.CLUSTER_ID
  COST_CENTER   = var.COST_CENTER
  DEPLOY_TYPE   = var.DEPLOY_TYPE
  ENVIRONMENT   = var.ENVIRONMENT
  NOTIFY_LIST   = var.NOTIFY_LIST
  OWNER_INFO    = var.OWNER_INFO
  PLATFORM      = var.PLATFORM
  SPONSOR_INFO  = var.SPONSOR_INFO
  REGION        = var.REGION
  DEPENDENCY    = [module.vnet-peer.depended_on]
}

module "aks-kube" {
  source = "../modules/aks-kube"

  AKS_RG_NAME          = azurerm_resource_group.aksrg.name
  AKS_SUBNET_ID        = module.aks-net.subnet_id[0]
  AZFW_PIP             = module.azfw.azfw_pip
  K8S_VER              = var.K8S_VER
  ADMIN_USER           = var.ADMIN_USER
  AKS_SSH_ADMIN_KEY    = var.AKS_SSH_ADMIN_KEY
  SERVICE_CIDR         = var.SERVICE_CIDR
  DNS_IP               = var.DNS_IP
  DOCKER_CIDR          = var.DOCKER_CIDR
  POD_CIDR             = var.POD_CIDR
  AUTH_IP_RANGES       = var.AUTH_IP_RANGES
  ENABLE_CA_DEF_POOL   = var.ENABLE_CA_DEF_POOL
  DEF_POOL_NODE_SIZE   = var.DEF_POOL_NODE_SIZE
  DEF_POOL_NAME        = var.DEF_POOL_NAME
  DEF_POOL_OS_DISK     = var.DEF_POOL_OS_DISK
  DEF_POOL_MIN         = var.DEF_POOL_MIN
  DEF_POOL_MAX         = var.DEF_POOL_MAX
  K8S_SP_CLIENT_ID     = var.K8S_SP_CLIENT_ID
  K8S_SP_CLIENT_SECRET = var.K8S_SP_CLIENT_SECRET
  # AAD_CLIENTAPP_ID = var.AAD_CLIENTAPP_ID
  # AAD_SERVERAPP_ID = var.AAD_SERVERAPP_ID
  # AAD_SERVERAPP_SECRET = var.AAD_SERVERAPP_SECRET
  CLUSTER_ID   = var.CLUSTER_ID
  COST_CENTER  = var.COST_CENTER
  DEPLOY_TYPE  = var.DEPLOY_TYPE
  ENVIRONMENT  = var.ENVIRONMENT
  NOTIFY_LIST  = var.NOTIFY_LIST
  OWNER_INFO   = var.OWNER_INFO
  PLATFORM     = var.PLATFORM
  SPONSOR_INFO = var.SPONSOR_INFO
  REGION       = var.REGION
  DEPENDENCY = [module.vnet-peer.depended_on,
    module.pre-aks-kube.depended_on,
    module.azfw.depended_on,
  azurerm_resource_group.aksrg.name]
}

module "aks-nodepool" {
  source = "../modules/aks-nodepool"

  AKS_ID        = module.aks-kube.aks_id
  AKS_SUBNET_ID = module.aks-net.subnet_id[0]
  NODEPOOL_DEFS = var.NODEPOOL_DEFS
  DEPENDENCY    = [module.aks-kube.depended_on]

}

module "post-aks-kube" {
  source = "../modules/post-aks-kube"

  AKS_RG_NAME      = azurerm_resource_group.aksrg.name
  AKS_VNET_NAME    = var.AKS_VNET_NAME
  AKS_SUBNET_NAME  = module.aks-net.subnet_name[0]
  AZFW_PRIV_IP     = module.azfw.azfw_PrivIP
  TF_CLIENT_SECRET = var.TFUSER_CLIENT_SECRET
  TF_CLIENT_ID     = var.TFUSER_CLIENT_ID
  TF_TENANT_ID     = var.TENANT_ID
  AKS_API_FQDN     = module.aks-kube.api_fqdn
  AZFW_NAME        = module.azfw.azfw_name
  AZFW_RG_NAME     = azurerm_resource_group.hubrg.name
  CLUSTER_ID       = var.CLUSTER_ID
  DEPENDENCY       = [module.aks-kube.depended_on]
}