terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.58.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "=2.9.0"
    }
  }
}

locals {
  location            = var.location 
  kubernetes_version  = var.kubernetes_version
  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  ssh_key             = var.ssh_key
  ssh_username        = "admin_user"
}

provider "azurerm" {
  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id

  skip_provider_registration = true
  features {}
}

# Create resource group under which we will 
# create all the resources 
resource "azurerm_resource_group" "rg" {
    name = "devops-finland-demo"
    location = var.location
}

# Create kubernetes cluster and image repository 
module "cluster" {
  source              = "./modules/cluster/"
  resource_group      = azurerm_resource_group.rg
  kubernetes_version  = local.kubernetes_version 
  admin_username      = local.ssh_username
  admin_ssh_key       = local.ssh_key
}

# Helm is nececary for KEDA
provider "helm" {
  kubernetes {
    host                   = module.cluster.host
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}

# Creates all nececary resources for keda 
# Event Hubs namespace, topic, consumer group 
module "keda" {
  source              = "./modules/keda/"
  target              = "/app/kubernetes"
  resource_group      = azurerm_resource_group.rg
}
