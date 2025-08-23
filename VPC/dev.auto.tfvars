application2 = {
  DB1 = {
    cidr_block = "10.1.1.0/24",
    az         = "us-east-1a",
    type       = "DB"
  },
  DB2 = {
    cidr_block = "10.1.2.0/24",
    az         = "us-east-1c",
    type       = "DB"
  },
  ALB1 = {
    cidr_block = "10.1.3.0/24",
    az         = "us-east-1a",
    type       = "ALB"
  },
  ALB2 = {
    cidr_block = "10.1.4.0/24",
    az         = "us-east-1c",
    type       = "ALB"
  },
  "SRV-SBC-SIP1" = {
    cidr_block = "10.1.5.0/24",
    az         = "us-east-1a",
    type       = "SBC"
  },
  "SRV-SBC-SIP2" = {
    cidr_block = "10.1.6.0/24",
    az         = "us-east-1c",
    type       = "SBC"
  },
  "SRV-VoiceMail-Dashboards1" = {
    cidr_block = "10.1.7.0/24",
    az         = "us-east-1a",
    type       = "Dashboard"
  },
  "SRV-VoiceMail-Dashboards2" = {
    cidr_block = "10.1.8.0/24",
    az         = "us-east-1c",
    type       = "Dashboard"
  },
  "SRV-IMAP1" = {
    cidr_block = "10.1.9.0/24",
    az         = "us-east-1a",
    type       = "IMAP"
  },
  "SRV-IMAP2" = {
    cidr_block = "10.1.10.0/24",
    az         = "us-east-1c",
    type       = "IMAP"
  },
  "SRV-Worker1" = {
    cidr_block = "10.1.11.0/24",
    az         = "us-east-1a",
    type       = "Worker"
  },
  "SRV-Worker2" = {
    cidr_block = "10.1.12.0/24",
    az         = "us-east-1c",
    type       = "Worker"
  }
}