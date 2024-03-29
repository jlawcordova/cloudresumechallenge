variable "project" {
  type        = string
  description = "The name of the project. This is used for resource naming and tagging."
}

variable "domain" {
  type        = string
  default     = null
  description = "The domain for the app."
  nullable    = true
}

variable "alarm_email" {
  type        = string
  default     = null
  description = "The email address where CloudWatch alarms are sent."
  nullable    = true
}

variable "environment" {
  type        = string
  default     = "development"
  description = "The type of environment where this Cloud Resume Challenge is deployed. This is used for resource tagging."
}
