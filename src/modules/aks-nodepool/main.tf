resource "azurerm_kubernetes_cluster_node_pool" "main" {
  lifecycle {
    ignore_changes = [
      "node_count"
    ]
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  name                  = var.POOL2_NAME
  node_count            = var.POOL2_MIN
  enable_auto_scaling   = var.ENABLE_CA_POOL2
  min_count             = var.POOL2_MIN
  max_count             = var.POOL2_MAX
  vm_size               = var.POOL2_NODE_SIZE
  os_disk_size_gb       = 128
  vnet_subnet_id        = azurerm_subnet.akssubnet.id
  os_type               = "Linux"
}