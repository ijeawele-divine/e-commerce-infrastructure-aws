locals {
  application_manifests = fileset("${path.module}/k8s/applications", "**/*.yaml")
  platform_manifests    = fileset("${path.module}/k8s/platform", "**/*.yaml")

  # exclude the secrets files — terraform manages those via external-secrets.tf
  filtered_platform = {
    for f in local.platform_manifests :
    "platform/${f}" => "${path.module}/k8s/platform/${f}"
    if !strcontains(f, "secrets/")
  }

  all_manifests = merge(
    { for f in local.application_manifests : "applications/${f}" => "${path.module}/k8s/applications/${f}" },
    local.filtered_platform
  )
}

resource "kubectl_manifest" "app_manifests" {
  for_each  = local.all_manifests
  yaml_body = file(each.value)

  wait_for_rollout = false

  depends_on = [
    kubectl_manifest.rider_external_secret,
    kubectl_manifest.driver_external_secret,
    kubectl_manifest.trip_external_secret,
    kubectl_manifest.matching_external_secret,
    kubectl_manifest.email_external_secret,
    kubectl_manifest.frontend_external_secret,
    helm_release.nginx_ingress,
    helm_release.cert_manager
  ]
}