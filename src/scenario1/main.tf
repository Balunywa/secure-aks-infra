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
  source       = "../modules/fw-net"
  CLUSTER_ID   = var.CLUSTER_ID
  COST_CENTER  = var.COST_CENTER
  DEPLOY_TYPE  = var.DEPLOY_TYPE
  ENVIRONMENT  = var.ENVIRONMENT
  NOTIFY_LIST  = var.NOTIFY_LIST
  OWNER_INFO   = var.OWNER_INFO
  PLATFORM     = var.PLATFORM
  SPONSOR_INFO = var.SPONSOR_INFO
  REGION       = var.REGION



}