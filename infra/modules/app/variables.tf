variable "environment" {
  type = string
  default = "development"
  description = "The type of environment where this Cloud Resume Challenge is deployed. This is used for resource tagging."
}

variable "project" {
  type = string
  default = "cloud-resume-challenge"
  description = "The name of the project. This is used for resource naming and tagging."
}
