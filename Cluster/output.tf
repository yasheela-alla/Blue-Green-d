output "aks_cluster_name" {
  description = "Name of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.y_aks.name
}

output "aks_node_resource_group" {
  description = "Resource group for the AKS nodes"
  value       = azurerm_kubernetes_cluster.y_aks.node_resource_group
}
