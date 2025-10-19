# External Secrets Operator Installation via Helm

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "external-secrets-system"
  version    = "0.20.3"  # Use a stable version

  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
      serviceMonitor = {
        enabled = false
      }
      prometheus = {
        enabled = false
      }
    })
  ]

  depends_on = [
    module.eks,
    aws_eks_addon.vpc_cni,
    aws_eks_addon.coredns,
    aws_eks_addon.kube_proxy
  ]
}
