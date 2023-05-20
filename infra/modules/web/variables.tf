variable "project" {
  type = string
  description = "The name of the project. This is used for resource naming and tagging."
}

variable "app_url" {
  type = string
  description = "The base URL of the app where the web application will make API calls to."
}

variable "environment" {
  type = string
  default = "development"
  description = "The type of environment where this Cloud Resume Challenge is deployed. This is used for resource tagging."
}