variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "altschool-capstone-rg"
}

variable "region" {
  description = "The location/region of the resource group"
  type        = string
  default     = "southafricanorth"
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "capstone_cluster"
}

variable "allowed_source_addresses" {
  description = "List of authorized ip addresses"
  type        = list(string)
}

# variable "client_id" {
#   description = "The client id of the service principal"
#   type        = string
# }

# variable "client_secret" {
#   description = "The client secret of the service principal"
#   type        = string
# }

# variable "tenant_id" {
#   description = "The tenant id of the service principal"
#   type        = string
# }

# variable "subscription_id" {
#   description = "The subscription id"
#   type        = string
# } 