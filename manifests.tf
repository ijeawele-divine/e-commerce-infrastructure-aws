locals {
  manifest_files = fileset("${path.module}/k8s/applications", "**/*.yaml")
}

resource "kubectl_manifest" "app_manifests" {
  for_each  = local.manifest_files
  yaml_body = file("${path.module}/k8s/applications/${each.value}")

  wait_for_rollout = false 
  
  depends_on = [
#    kubernetes_namespace.app,
    module.eks,
    kubectl_manifest.rider_external_secret,
    kubectl_manifest.driver_external_secret,
    kubectl_manifest.trip_external_secret,
    kubectl_manifest.matching_external_secret,
    kubectl_manifest.email_external_secret,
    kubectl_manifest.frontend_external_secret,
    helm_release.nginx_ingress,
    helm_release.external_secrets,
    module.eks.node_group_status,
    helm_release.cert_manager
  ]
}