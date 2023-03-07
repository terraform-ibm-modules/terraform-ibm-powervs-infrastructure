variable "cloud_connection_validate" {
  description = "Verify reuse_cloud_connection and transit_gateway_name variables"
  type = object({
    reuse_cloud_connections = bool
    transit_gateway_name    = string
  })

  validation {
    condition     = (!var.cloud_connection_validate.reuse_cloud_connections && var.cloud_connection_validate.transit_gateway_name != null && var.cloud_connection_validate.transit_gateway_name != "") || var.cloud_connection_validate.reuse_cloud_connections
    error_message = "If reusing cloud connections, Transit gateway name must be provided."
  }
}

variable "example_valid" {
  description = "To check if the example is valid."
  type = object(
    {
      valid         = string
      error_message = string
    }
  )

  validation {
    condition     = var.example_valid.valid
    error_message = var.example_valid.error_message
  }
}
