variable "az" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "application" {
  type = map(string)
  default = {
    DBs                        = "DBs"
    ALB                        = "ALB"
    "SRV-SBC-SIP"              = "SRV-SBC-SIP"
    "SRV-VoiceMail-Dashboards" = "SRV-VoiceMail-Dashboards"
    "SRV-IMAP"                 = "SRV-IMAP"
    "SRV-Worker"               = "SRV-Worker"
  }
}

variable "application2" {
  type = map(object({
    cidr_block = string,
    az         = string,
    type       = string
    }
  ))
  #   default = {
  #     DBs = {
  #       name       = "DBs"
  #       cidr_block = "10.1.1.0/24"
  #     },
  #     ALB = {
  #       name       = "ALB"
  #       cidr_block = "10.1.2.0/24"
  #     },
  #     "SRV-SBC-SIP" = {
  #       name       = "SRV-SBC-SIP"
  #       cidr_block = "10.1.3.0/24"
  #     },
  #     "SRV-VoiceMail-Dashboards" = {
  #       name       = "SRV-VoiceMail-Dashboards"
  #       cidr_block = "10.1.4.0/24"
  #     },
  #     "SRV-IMAP" = {
  #       name       = "SRV-IMAP"
  #       cidr_block = "10.1.5.0/24"
  #     },
  #     "SRV-Worker" = {
  #       name       = "SRV-Worker"
  #       cidr_block = "10.1.6.0/24"
  #     }
  #   }
}