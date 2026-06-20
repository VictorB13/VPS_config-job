variable "digitalocean_token" {
    description  = "DigitalOCean API token"
    type = string
    sensitive = true
}

variable "region" {
    description  = "DigitalOcean region"
    type = string
}

variable "vps_size" {
    description = "Size of the VPS to create"
    type = string
    default = "s-1vcpu-1gb"
}

variable "root_password" {
    description = "Root password for SSH access to the droplet"
    type        = string
    sensitive   = true
}




