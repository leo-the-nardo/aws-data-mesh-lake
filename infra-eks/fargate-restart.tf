# Restart pods after Fargate profile updates
# This ensures pods don't get stuck in Pending state when Fargate profiles change

resource "null_resource" "restart_fargate_pods" {
  # Trigger on Fargate profile changes
  triggers = {
    fargate_profile_id = module.eks.fargate_profiles["main"].fargate_profile_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Cleaning up pending pods after Fargate profile update..."
      
      # Wait for Fargate profile to be active
      sleep 30
      
      # Delete all pending pods to force recreation with new Fargate profile
      kubectl delete pods --field-selector=status.phase=Pending -A || true
      
      echo "Pending pods cleanup completed"
    EOT
    
    environment = {
      KUBECONFIG = ""  # Use default kubeconfig
    }
  }

  depends_on = [
    module.eks,
    helm_release.external_secrets,
    module.eks_blueprints_addons
  ]
}

