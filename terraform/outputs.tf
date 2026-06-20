output "vps_ip" {
    description = "The public IP of the created VPS"
    value       = digitalocean_droplet.demo_vps.ipv4_address
}

output "root_password" {
    description = "The root password for SSH access"
    value       = nonsensitive(var.root_password)
}