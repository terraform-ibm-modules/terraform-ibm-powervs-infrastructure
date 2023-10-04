variable "cloud_connection_validate" {
  description = "Verify reuse_cloud_connection and transit_gateway_id variables"
  type = object({
    reuse_cloud_connections = bool
    transit_gateway_id      = string
  })

  validation {
    condition     = (!var.cloud_connection_validate.reuse_cloud_connections && var.cloud_connection_validate.transit_gateway_id != null && var.cloud_connection_validate.transit_gateway_id != "") || var.cloud_connection_validate.reuse_cloud_connections
    error_message = "If reusing cloud connections, Transit gateway id must be provided."
  }
}
