# MSK Cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = var.msk_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(data.aws_subnets.private.ids)

  broker_node_group_info {
    instance_type   = var.msk_instance_type
    client_subnets  = data.aws_subnets.private.ids
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.msk_storage_size
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.main.arn
    revision = aws_msk_configuration.main.latest_revision
  }

  tags = var.tags
}

# MSK Configuration
resource "aws_msk_configuration" "main" {
  kafka_versions = [var.kafka_version]
  name           = "${var.msk_cluster_name}-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
default.replication.factor=1
min.insync.replicas=1
num.partitions=1
PROPERTIES
}
