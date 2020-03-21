/*
 * TF Base
 */
variable "TFUSER_CLIENT_ID" {
}

variable "TFUSER_CLIENT_SECRET" {
}

variable "TENANT_ID" {
}

variable "SUB_ID" {
}

/*
 * Common
 */
variable "REGION" {
}

variable "CLUSTER_ID" {
}

variable "COST_CENTER" {
  description = "Cost center #"
}

variable "DEPLOY_TYPE" {
  description = "Deployment type for tags"
}

variable "ENVIRONMENT" {
  description = "Environment info"
}

variable "NOTIFY_LIST" {
  description = "notification list"
}

variable "OWNER_INFO" {
}

variable "PLATFORM" {
}

variable "SPONSOR_INFO" {
}
/*
* AZFW
*/
variable "HUB_VNET_ADDR_SPACE" {
  type        = list
  description = "The address space that is used by the virtual network."
}

variable "HUB_SUBNET_NAMES" {
  description = "A map of public subnets inside the vNet subnetName=subnetcidr should be the pattern used."
  type        = map
}
/*
* AZFW
*/
variable "DOCKER_REGISTRY" {
  type = string
}
/*
 * AKS-VNET
 */

variable "AKS_VNET_NAME" {
  type        = string
  description = "The name of the virtual network to create."
}

variable "AKS_VNET_CIDR" {
  type        = list
  description = "The name of the virtual network to create."
}

variable "AKS_SUBNET_NAMES" {
  description = "A map of public subnets inside the vNet subnetName=subnetcidr should be the pattern used."
  type        = map
}

variable "DNS_SERVERS" {
  type        = list
  default     = []
  description = ""
}


