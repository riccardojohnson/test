provider "azurerm" {
   version = "~>2.00"
   #features {}
   subscription_id = var.subscription_id
   tenant_id = var.tenant_id
   client_id = var.client_id
   client_secret = var.client_secret
}

variable "location" {

}

variable "rg_name" {
   
}

variable "subscription_id" {

}

variable "client_id" {

}

variable "client_secret" {
 
}

variable "tenant_id" {
  
}