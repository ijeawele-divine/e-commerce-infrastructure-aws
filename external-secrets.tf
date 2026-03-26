# external-secrets.tf

resource "kubectl_manifest" "secret_store" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: aws-secrets-manager
    spec:
      provider:
        aws:
          service: SecretsManager
          region: eu-north-1
          auth:
            jwt:
              serviceAccountRef:
                name: external-secrets
                namespace: external-secrets
  YAML

  depends_on = [helm_release.external_secrets]
}

resource "kubectl_manifest" "rider_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: rider-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: rider-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-rider-service
  YAML

  depends_on = [kubectl_manifest.secret_store]
}

resource "kubectl_manifest" "driver_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: driver-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: driver-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-driver-service
  YAML

  depends_on = [kubectl_manifest.secret_store]
}

resource "kubectl_manifest" "trip_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: trip-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: trip-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-trip-service
  YAML

  depends_on = [kubectl_manifest.secret_store]
}

resource "kubectl_manifest" "matching_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: matching-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: matching-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-matching-service
  YAML

  depends_on = [kubectl_manifest.secret_store]
}

resource "kubectl_manifest" "email_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: email-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: email-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-email-service
  YAML

  depends_on = [kubectl_manifest.secret_store]
}

resource "kubectl_manifest" "frontend_external_secret" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: frontend-aws-secret
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: aws-secrets-manager
        kind: SecretStore
      target:
        name: frontend-aws-secret
        creationPolicy: Owner
      dataFrom:
        - extract:
            key: teleios-divine-${var.environment}-frontend
  YAML

  depends_on = [kubectl_manifest.secret_store]
}