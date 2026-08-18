resource "local_file" "namespace_manifest" {
  content = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.app_name
    }
  })
  filename = "${path.module}/manifests/01-namespace.yaml"
}

resource "local_file" "storageclass_manifest" {
  content = yamlencode({
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "oci-bv"
    }
    provisioner = "blockvolume.csi.oraclecloud.com"
    parameters = {
      "csi.storage.k8s.io/fstype" = "ext4"
    }
    reclaimPolicy    = "Retain"
    volumeBindingMode = "WaitForFirstConsumer"
  })
  filename = "${path.module}/manifests/02-storageclass.yaml"
}

resource "local_file" "pv_manifest" {
  content = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolume"
    metadata = {
      name = "${var.app_name}-pv"
    }
    spec = {
      capacity = {
        storage = "${var.block_volume_size_gbs}Gi"
      }
      accessModes      = ["ReadWriteOnce"]
      persistentVolumeReclaimPolicy = "Retain"
      storageClassName = "oci-bv"
      csi = {
        driver       = "blockvolume.csi.oraclecloud.com"
        volumeHandle = oci_core_volume.app_volume.id
        fsType       = "ext4"
      }
    }
  })
  filename = "${path.module}/manifests/03-pv.yaml"
}

resource "local_file" "pvc_manifest" {
  content = yamlencode({
    apiVersion = "v1"
    kind       = "PersistentVolumeClaim"
    metadata = {
      name      = "${var.app_name}-pvc"
      namespace = var.app_name
    }
    spec = {
      accessModes      = ["ReadWriteOnce"]
      storageClassName = "oci-bv"
      volumeName       = "${var.app_name}-pv"
      resources = {
        requests = {
          storage = "${var.block_volume_size_gbs}Gi"
        }
      }
    }
  })
  filename = "${path.module}/manifests/04-pvc.yaml"
}

resource "local_file" "deployment_manifest" {
  content = yamlencode({
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.app_name
      namespace = var.app_name
      labels = {
        app = var.app_name
      }
    }
    spec = {
      replicas = var.app_replicas
      selector = {
        matchLabels = {
          app = var.app_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.app_name
          }
        }
        spec = {
          containers = [
            {
              name  = var.app_name
              image = var.app_image
              ports = [
                {
                  containerPort = var.app_port
                  name          = "http"
                }
              ]
              volumeMounts = [
                {
                  mountPath = "/usr/share/nginx/html"
                  name      = "app-storage"
                }
              ]
              resources = {
                requests = {
                  cpu    = "100m"
                  memory = "128Mi"
                }
                limits = {
                  cpu    = "500m"
                  memory = "256Mi"
                }
              }
            }
          ]
          volumes = [
            {
              name = "app-storage"
              persistentVolumeClaim = {
                claimName = "${var.app_name}-pvc"
              }
            }
          ]
        }
      }
    }
  })
  filename = "${path.module}/manifests/05-deployment.yaml"
}

resource "local_file" "service_manifest" {
  content = yamlencode({
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "${var.app_name}-lb"
      namespace = var.app_name
      annotations = {
        "oci.oraclecloud.com/load-balancer-type"                  = "lb"
        "service.beta.kubernetes.io/oci-load-balancer-shape"      = "flexible"
        "service.beta.kubernetes.io/oci-load-balancer-shape-flex-min" = "10"
        "service.beta.kubernetes.io/oci-load-balancer-shape-flex-max" = "10"
      }
    }
    spec = {
      type     = "LoadBalancer"
      selector = {
        app = var.app_name
      }
      ports = [
        {
          name       = "http"
          protocol   = "TCP"
          port       = 80
          targetPort = var.app_port
        }
      ]
    }
  })
  filename = "${path.module}/manifests/06-service-lb.yaml"
}
