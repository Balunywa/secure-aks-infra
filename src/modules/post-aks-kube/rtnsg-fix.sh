#!/bin/bash

set -e

az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_SECRET --tenant $AZ_TENANT_ID

echo "Configuring network..."

echo "Retrieving AKS resource group, route table and network sucurity group..."
AKS_MC_RG=$(az group list --query "[?starts_with(name, 'MC_${AKS_VNET_RG}')].name | [0]" --output tsv)

echo "Resource group: ".$AKS_MC_RG

AKS_ROUTE_TABLE_ID=$(az network route-table list -g ${AKS_MC_RG} --query "[].id | [0]" -o tsv)
AKS_ROUTE_TABLE_NAME=$(az network route-table list -g ${AKS_MC_RG} --query "[].name | [0]" -o tsv)
AKS_NODE_SUBNET_ID=$(az network vnet subnet show -g ${AKS_VNET_RG} --name ${AKS_SUBNET_NAME} --vnet-name ${AKS_VNET_NAME} --query id -o tsv)
AKS_NODE_NSG=$(az network nsg list -g ${AKS_MC_RG} --query "[].id | [0]" -o tsv)


az network vnet subnet update \
--route-table "" \
--network-security-group "" \
--ids $AKS_NODE_SUBNET_ID

echo "Network configuration has been successfuly cleaned."

echo "Updating VNET..."
echo "Route table ID: ".$AKS_ROUTE_TABLE_ID.", Route table name: ".$AKS_ROUTE_TABLE_NAME.", Network Security Group:".$AKS_NODE_NSG.", Subnet ID:".$AKS_NODE_SUBNET_ID

az network route-table route create \
  --name RouteTovDMZ \
  --resource-group $AKS_MC_RG \
  --route-table-name $AKS_ROUTE_TABLE_NAME \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $AZFW_INT_IP

az network vnet subnet update \
--route-table $AKS_ROUTE_TABLE_ID \
--network-security-group $AKS_NODE_NSG \
--ids $AKS_NODE_SUBNET_ID

echo "Network has been successfuly configured."
