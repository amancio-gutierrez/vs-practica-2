variable "project_name" {
  default = "matomo-infra"
}

variable "mariadb_root_password" {
  description = "Root password for MariaDB"
  type        = string
  sensitive   = true
  default     = "supersecretroot"
}

variable "mariadb_user_password" {
  description = "User password for Matomo DB"
  type        = string
  sensitive   = true
  default     = "matomopass"
}

variable "matomo_image" {
  description = "Docker image for Matomo"
  type        = string
  # Cambia esto por tu imagen de Docker Hub: tu_usuario/matomo-custom:latest
  default     = "amancito/matomo-custom:latest" 
}