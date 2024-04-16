variable "project_id" {
  type = string
  description = "The Project ID to deploy resources in"
}

variable "region" {
    type = string
    description = "The region to deploy resources in"

}

variable "use_private_service_connect" {
    type = bool
    description = "Should Private Service Connect be used for the control plane?"
}
