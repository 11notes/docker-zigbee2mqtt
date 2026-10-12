terraform {
  required_version = ">= 1.15.0"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 3.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

variable "fqdn" {
  type = string
}

variable "wildcard_fqdn" {
  type = string
}

variable "ingress_password" {
  type = string
  sensitive = true
}

resource "kubernetes_namespace_v1" "zigbee2mqtt" {
  metadata {
    name = "zigbee2mqtt"
  }
}

resource "helm_release" "zigbee2mqtt" {
  name = "zigbee2mqtt"
  repository = "oci://ghcr.io/11notes/charts"
  chart = "zigbee2mqtt"
  namespace = "zigbee2mqtt"
  version = "0.0.2"
}

resource "kubernetes_secret_v1" "ingress_auth" {
  metadata {
    name = "ingress-auth"
    namespace = "traefik"
  }

  data = {
    users = "admin:${bcrypt(trimspace(var.ingress_password))}"
  }

  type = "Opaque"
}

resource "kubernetes_manifest" "ingress_auth" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind = "Middleware"
    metadata = {
      name = "ingress-auth"
      namespace = "traefik"
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret_v1.ingress_auth.metadata[0].name
      }
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "ingress"
    namespace = "zigbee2mqtt"
    annotations = {
      "traefik.ingress.kubernetes.io/router.middlewares" = "zigbee2mqtt-ingress-auth@kubernetescrd"
    }
  }

  spec {
    ingress_class_name = "traefik"

    tls {
      hosts = [trimspace(var.fqdn)]
      secret_name = trimspace(var.wildcard_fqdn)
    }

    rule {
      host = trimspace(var.fqdn)
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "zigbee2mqtt"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}