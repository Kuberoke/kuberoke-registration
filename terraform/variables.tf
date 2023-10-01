variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "ticket_codes" {
  type        = map
  description = "Ticket codes to be created on initial setup. Changes of the values will be ignored by terraform."

  default = {
    invalid = "0"
  }
}

variable "sendgrid_api_key" {
  type        = string
  description = "API key for sendgrid"
}