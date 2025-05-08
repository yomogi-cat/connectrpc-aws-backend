variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

locals {
  project_name = "sample-batch-${var.environment}"
  _env = {
    dev = {
      container_base_config = {
        essential = true
        cpu       = 256
        memory    = 512

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/${local.project_name}"
            "awslogs-region"        = "ap-northeast-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
      }
      batch_cleanup_params  = "cleanup --older-than 2023-01-01T00:00:00Z --only-completed"
      batch_export_params   = "export --destination s3 --format json"
      batch_stats_params    = "stats --period daily"
      log_retention_in_days = 0
    }
    prod = {
      container_base_config = {
        essential = true
        cpu       = 256
        memory    = 512

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/${local.project_name}"
            "awslogs-region"        = "ap-northeast-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
      }
      batch_cleanup_params  = "cleanup --older-than 2023-01-01T00:00:00Z --only-completed"
      batch_export_params   = "export --destination s3 --format json"
      batch_stats_params    = "stats --period daily"
      log_retention_in_days = 0
    }
  }
}

locals {
  env = local._env[var.environment]
}

