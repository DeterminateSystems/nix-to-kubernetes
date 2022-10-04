output "nomad-client-ip" {
  value = digitalocean_droplet.nomad-client.ipv4_address
}
