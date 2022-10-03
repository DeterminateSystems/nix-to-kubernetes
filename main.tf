terraform {
  required_version = "1.3.1"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.22.1"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "nomad" {
  name       = "nomad"
  public_key = file("~/.ssh/nix-nomad.pub")
}

resource "digitalocean_droplet" "nomad-client" {
  name   = "nomad-client"
  image  = "ubuntu-22-04-x64"
  size   = "s-2vcpu-4gb"
  region = var.do_region
  ssh_keys = [
    digitalocean_ssh_key.nomad.fingerprint
  ]

  connection {
    type  = "ssh"
    user  = "root"
    host  = self.ipv4_address
    agent = true
  }
}

output "nomad-client-ip" {
  value = digitalocean_droplet.nomad-client.ipv4_address
}
