variable "ami" {}
variable "instance_type" {}
variable "spot_az1" {}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "AKloud-Console"
}