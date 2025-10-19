# MSK Cluster
resource "aws_msk_cluster" "main" {
  count                 = var.enable_msk ? 1 : 0
  cluster_name           = var.msk_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(data.terraform_remote_state.network.outputs.private_subnets)

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    client_subnets  = data.terraform_remote_state.network.outputs.private_subnets
    security_groups = [aws_security_group.msk[0].id]

    storage_info {
      ebs_storage_info {
        volume_size = var.msk_storage_size
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.main[0].arn
    revision = aws_msk_configuration.main[0].latest_revision
  }

  tags = var.tags
}

# MSK Configuration
resource "aws_msk_configuration" "main" {
  count          = var.enable_msk ? 1 : 0
  kafka_versions = [var.kafka_version]
  name           = "${var.msk_cluster_name}-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
default.replication.factor=1
min.insync.replicas=1
num.partitions=1
PROPERTIES
}
