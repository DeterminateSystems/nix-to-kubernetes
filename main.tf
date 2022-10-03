terraform {
  required_version = "1.3.1"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.22.1"
    }
  }
}

resource "digitalocean_ssh_key" "nomad" {
  name       = "nomad"
  public_key = file("~/.ssh/nix-nomad.pub")
}
