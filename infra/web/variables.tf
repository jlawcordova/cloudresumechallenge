variable "project" {
  type = string
  default = ""
  description = "The name of the project. This is used for resource naming and tagging."
}

variable "app_url" {
  type = string
  description = "The URL for Cloud Resume Challenge API Gateway."
}

variable "environment" {
  type = string
  default = "development"
  description = "The type of environment where this Cloud Resume Challenge is deployed. This is used for resource tagging."
}