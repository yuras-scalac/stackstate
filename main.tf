terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.7.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "null_resource" "servicemonitor-crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
  }
}

resource "helm_release" "custom" {
  depends_on          = [null_resource.servicemonitor-crds]
  name       = "custom"
  namespace  = "default" 

  repository = "custom-deploy"
  chart      = "./custom-deploy"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  depends_on          = [helm_release.argo]
  name       = "prometheus"
  namespace  = "monitoring" 

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  timeout    = 600
}

resource "null_resource" "grafana_import_dashboards" {
  depends_on = [helm_release.prometheus]
  provisioner "local-exec" {
    command = "kubectl apply -f ds.yml"
  }
}

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "helm_release" "argo" {
  name       = "argo"
  namespace  = "argo"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "argo-cd"
  timeout    = 600
}

resource "null_resource" "argo-setup" {
  depends_on = [helm_release.argo]
  provisioner "local-exec" {
    command = <<-EOT
      PASS=`kubectl -n argo get secret argocd-secret -o jsonpath={.data.clearPassword} | base64 -d`
      echo $PASS
      kubectl port-forward --namespace argo svc/argo-argo-cd-server 8080:80 &
      argocd login --insecure localhost:8080 --username admin --password $PASS
      argocd app create sock-shop --repo https://github.com/yuras-scalac/sock-shop.git --path deploy/kubernetes/ --dest-server https://kubernetes.default.svc --dest-namespace sock-shop --sync-policy automated --auto-prune --self-heal
      pkill kubectl
    EOT
  }
}
