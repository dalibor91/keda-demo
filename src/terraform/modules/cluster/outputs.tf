# output "kube_config" {
#     value = azurerm_kubernetes_cluster.cluster.kube_admin_config
#     sensitive = true
# }

output "cluster_ca_certificate" {
    value = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

output "client_certificate" {
    value = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_certificate)
}

output "client_key" {
    value = base64decode(azurerm_kubernetes_cluster.cluster.kube_config[0].client_key)
}

output "host" {
    value = azurerm_kubernetes_cluster.cluster.kube_config[0].host
}

output "username" {
    value = azurerm_kubernetes_cluster.cluster.kube_config[0].username
}

output "password" {
    value = azurerm_kubernetes_cluster.cluster.kube_config[0].password
}