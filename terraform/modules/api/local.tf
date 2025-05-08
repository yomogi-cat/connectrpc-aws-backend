variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

locals {
  project_name = "sample-app-${var.environment}"
  _env = {
    dev = {
    }
    prod = {

    }
  }
}

locals {
  env = local._env[var.environment]
}

