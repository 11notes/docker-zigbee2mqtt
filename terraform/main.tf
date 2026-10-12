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
  version = "0.0.1"
}