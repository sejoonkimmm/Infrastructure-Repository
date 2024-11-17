variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "replication_password" {
  description = "PostgreSQL replication password"
  type        = string
  sensitive   = true
}