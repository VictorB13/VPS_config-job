resource "digitalocean_droplet" "demo_vps" {
    image  = "ubuntu-22-04-x64"
    name   = "demo-vps"
    region = var.region
    size   = var.vps_size
    tags   = ["demo"]

    user_data = <<-EOF
        #cloud-config
        chpasswd:
          list: |
            root:${var.root_password}
          expire: False
        ssh_pwauth: true
    EOF
}