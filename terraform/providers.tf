# Configure the DigitalOcean provider and specify the required version
terraform {
    required_providers {
        digitalocean = {
            source = "digitalocean/digitalocean"
            version = "~> 2.0"
        }
    }
}

# Configure the DigitalOcean provider with the API token from the variables
provider "digitalocean" {
    token = var.digitalocean_token
}