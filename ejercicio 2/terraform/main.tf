terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.2.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.default.kubeconfig_path
}

# Configuración del Cluster Kind
resource "kind_cluster" "default" {
  name = var.project_name

  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # Mapeo de puerto Host 8081 -> Container 30081 (NodePort)
      extra_port_mappings {
        container_port = 30081
        host_port      = 8081
        listen_address = "0.0.0.0"
      }

		# Mapeo para persistencia real
      extra_mounts {
        host_path      = replace(abspath("${path.module}/../data/mariadb"), "\\", "/")
        container_path = "/var/local-data/mariadb"
      }
      extra_mounts {
        host_path      = replace(abspath("${path.module}/../data/matomo"), "\\", "/")
        container_path = "/var/local-data/matomo"
      }
    }
  }
}