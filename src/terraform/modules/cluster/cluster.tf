resource "azurerm_kubernetes_cluster" "cluster" {
    name = "devops-finland-demo" 
    location = var.resource_group.location 
    resource_group_name = var.resource_group.name

    dns_prefix = "devops-finland-demo"
    kubernetes_version = var.kubernetes_version 

    default_node_pool {
        name                 = "default"
        vm_size              = "Standard_DS3_v2"
        os_disk_size_gb      = 128
        type                 = "VirtualMachineScaleSets"
        node_count           = 1
        max_pods             = 150
        enable_auto_scaling  = true
        min_count            = 1
        max_count            = 10
    }

    linux_profile {
        admin_username = var.admin_username

        ssh_key {
            key_data = var.admin_ssh_key
        }
    }

    identity {
        type = "SystemAssigned"
    }

    role_based_access_control_enabled = true
}

resource "azurerm_container_registry" "acr" {
  name                = "dfdacr" # devops-finland-demo-acr (Error: alpha numeric characters only are allowed in "name": "devops-finland-demo")
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location 
  sku                 = "Premium"
  admin_enabled       = true
}