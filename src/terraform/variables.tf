# variable "serviceprinciple_id" {
#     default = ""
# }

# variable "serviceprinciple_key" {
# }

variable "tenant_id" {
    type = string 
    description = "Azure Tenant ID. (Check TF_VAR_)"
}

variable "subscription_id" {
    type = string 
    description = "Azure Subscription ID. (Check TF_VAR_)"
}

variable "ssh_key" {
    type = string 
    description = "SSH key that will be used for servers. (Check TF_VAR_)"
}

variable "location" {
  default = "westeurope"
  description = "Location of resources. (Check TF_VAR_)"
}

variable "kubernetes_version" {
    default = "1.24.9"
    type = string 
    description = "Version of kubernetes. (Check TF_VAR_)"
}