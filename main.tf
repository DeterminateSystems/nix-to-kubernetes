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
  image  = var.nomad_image
  size   = var.nomad_client_size
  region = var.do_region
  ssh_keys = [
    digitalocean_ssh_key.nomad.id
  ]

  connection {
    type  = "ssh"
    user  = "root"
    host  = self.ipv4_address
    agent = true
  }
}

resource "digitalocean_droplet" "nomad-server" {
  name   = "nomad-server-${count.index + 1}"
  count  = var.nomad_server_count
  image  = var.nomad_image
  size   = var.nomad_server_size
  region = var.do_region
}
