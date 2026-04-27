variable "aws_region" {
  description = "AWS region for all MAXWELL resources"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Project name tag applied to all resources"
  type        = string
  default     = "MAXWELL"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "cost_center" {
  description = "Cost center tag for billing"
  type        = string
  default     = "maxwell-observatory"
}

variable "owner" {
  description = "Owner tag for resource attribution"
  type        = string
  default     = "MAXWELL-Team"
}
