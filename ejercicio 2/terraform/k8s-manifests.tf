# --- PERSISTENCIA (Persistent Volumes & Claims) ---

# --- PERSISTENCIA MARIADB ---

resource "kubernetes_persistent_volume" "mariadb_pv" {
  metadata { name = "mariadb-pv" }
  spec {
    capacity = { storage = "5Gi" }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "manual"
    persistent_volume_source {
      host_path {
        path = "/var/local-data/mariadb"
      }
    }
  }
  depends_on = [kind_cluster.default]
}

resource "kubernetes_persistent_volume_claim" "mariadb_pvc" {
  metadata { name = "mariadb-pvc" }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "manual"
    resources { requests = { storage = "5Gi" } }
    volume_name = kubernetes_persistent_volume.mariadb_pv.metadata.0.name
  }
  depends_on = [kubernetes_persistent_volume.mariadb_pv]
}

# --- PERSISTENCIA MATOMO ---

resource "kubernetes_persistent_volume" "matomo_pv" {
  metadata { name = "matomo-pv" }
  spec {
    capacity = { storage = "5Gi" }
    access_modes = ["ReadWriteOnce"]
    # IMPORTANTE
    storage_class_name = "manual"
    persistent_volume_source {
      host_path {
        path = "/var/local-data/matomo"
      }
    }
  }
  depends_on = [kind_cluster.default]
}

resource "kubernetes_persistent_volume_claim" "matomo_pvc" {
  metadata { name = "matomo-pvc" }
  spec {
    access_modes = ["ReadWriteOnce"]
    # IMPORTANTE
    storage_class_name = "manual"
    resources { requests = { storage = "5Gi" } }
    volume_name = kubernetes_persistent_volume.matomo_pv.metadata.0.name
  }
  depends_on = [kubernetes_persistent_volume.matomo_pv]
}

# --- MARIADB DEPLOYMENT & SERVICE ---

resource "kubernetes_service" "mariadb" {
  metadata { name = "mariadb" }
  spec {
    selector = { app = "mariadb" }
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_deployment" "mariadb" {
  metadata { name = "mariadb" }
  spec {
    replicas = 1
    selector { match_labels = { app = "mariadb" } }
    template {
      metadata { labels = { app = "mariadb" } }
      spec {
        container {
          image = "mariadb:10.6"
          name  = "mariadb"

          env {
            name  = "MARIADB_ROOT_PASSWORD"
            value = var.mariadb_root_password
          }
          env {
            name  = "MARIADB_DATABASE"
            value = "matomo"
          }
          env {
            name  = "MARIADB_USER"
            value = "matomo"
          }
          env {
            name  = "MARIADB_PASSWORD"
            value = var.mariadb_user_password
          }

          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mariadb-storage"
          persistent_volume_claim { claim_name = kubernetes_persistent_volume_claim.mariadb_pvc.metadata.0.name }
        }
      }
    }
  }
}

# --- MATOMO DEPLOYMENT & SERVICE ---

resource "kubernetes_service" "matomo" {
  metadata { name = "matomo" }
  spec {
    type = "NodePort"
    selector = { app = "matomo" }
    port {
      port        = 81     # Puerto del servicio interno
      target_port = 81     # Puerto del contenedor (configurado en Dockerfile)
      node_port   = 30081  # Puerto estático mapeado al host 8081
    }
  }
}

resource "kubernetes_deployment" "matomo" {
  metadata { name = "matomo" }
  spec {
    replicas = 1
    selector { match_labels = { app = "matomo" } }
    template {
      metadata { labels = { app = "matomo" } }
      spec {
        container {
          image = var.matomo_image
          name  = "matomo"

          env {
            name  = "MATOMO_DATABASE_HOST"
            value = "mariadb"
          }
          env {
            name  = "MATOMO_DATABASE_USERNAME"
            value = "matomo"
          }
          env {
            name  = "MATOMO_DATABASE_PASSWORD"
            value = var.mariadb_user_password
          }
          env {
            name  = "MATOMO_DATABASE_DBNAME"
            value = "matomo"
          }

          env {
            name  = "PHP_MEMORY_LIMIT"
            value = "512M"
          }

          port {
            container_port = 81
          }

          volume_mount {
            name       = "matomo-storage"
            mount_path = "/var/www/html"
          }
        }
        volume {
          name = "matomo-storage"
          persistent_volume_claim { claim_name = kubernetes_persistent_volume_claim.matomo_pvc.metadata.0.name }
        }
      }
    }
  }
}