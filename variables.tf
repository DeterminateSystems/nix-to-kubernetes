variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "do_region" {
  type        = string
  default     = "nyc1"
  description = "The DigitalOcean region to use"
}

variable "num_nomad_servers" {
  type        = number
  default     = 1
  description = "The number of Nomad servers to run"
}
