CLUSTER_ID          = "tst1"
COST_CENTER         = "RC8765"
DEPLOY_TYPE         = "AKS_WCNP"
ENVIRONMENT         = "PROD"
NOTIFY_LIST         = "mngrs@microsoft.com"
OWNER_INFO          = "tstgrp"
PLATFORM            = "azk8s"
SPONSOR_INFO        = "BizDev"
REGION              = "centralus"
HUB_VNET_ADDR_SPACE = ["192.168.0.0/24"]
HUB_SUBNET_NAMES = {
  azfw-subnet = "192.168.0.0/26"
}
DOCKER_REGISTRY = "ejvlab.azurecr.io"
AKS_VNET_NAME   = "aks-vnet-centraulus-001"
AKS_VNET_CIDR   = ["172.20.0.0/16"]
AKS_SUBNET_NAMES = {
  azfw-subnet = "172.20.0.0/21"
}
