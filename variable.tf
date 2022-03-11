variable "subscription_id" {}
variable "tenant_id" {}
variable "administrator_login" {}
variable "administrator_login_password" {}



variable "location" {
  type        = string
  description = "Location"
  default     = "westeurope"
}
variable "team" {
  type        = string
  description = "team name for tags "
  default     = "VOVteam"
}
variable "prefix" {
  default = "olli"
}
