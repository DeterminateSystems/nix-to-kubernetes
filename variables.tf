variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "do_region" {
  type        = string
  description = "The DigitalOcean region to use"
}

variable "nomad_image" {
  type        = string
  description = "Droplet image to use for Nomad"
}

variable "nomad_server_count" {
  type        = number
  description = "The number of Nomad servers to run"
}

variable "nomad_client_size" {
  type        = string
  description = "Nomad client Droplet size"
}

variable "nomad_server_size" {
  type        = string
  description = "Nomad server Droplet size"
}
