variable "name" {
  description = "The name of the Front Door."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Frontdoor should be created."
  type        = string
}

variable "backend_pools" {
  description = "A list of backend pools."
  type = list(object({
    name = string
    backends = list(object({
      enabled     = bool
      address     = string
      host_header = string
      http_port   = number
      https_port  = number
      priority    = number
      weight      = number
    }))
    load_balancing_name = string
    health_probe_name   = string
  }))
}

variable "backend_pool_health_probes" {
  description = "A list of the backend pool health probes."
  type = list(object({
    name                = string
    enabled             = bool
    path                = string
    protocol            = string
    probe_method        = string
    interval_in_seconds = number
  }))
}

variable "backend_pool_load_balancings" {
  description = "A list of the backend pool load balancing."
  type = list(object({
    name                            = string
    sample_size                     = number
    successful_samples_required     = number
    additional_latency_milliseconds = number
  }))
}

variable "backend_pools_send_receive_timeout_seconds" {
  description = "Timeout on forwarding request to the backend."
  type        = number
  default     = 60

  validation {
    condition     = var.backend_pools_send_receive_timeout_seconds >= 0 && var.backend_pools_send_receive_timeout_seconds <= 240
    error_message = "Possible values are between 0 and 240."
  }
}

variable "enforce_backend_pools_certificate_name_check" {
  description = "Enforce certificate name check on HTTPS for all backend pools."
  type        = bool
  default     = true
}

variable "load_balancer_enabled" {
  description = "Should the Frontdoor load balancer be enabled ?"
  type        = bool
  default     = true
}

variable "friendly_name" {
  description = "A friendly name for the Frontdoor."
  type        = string
  default     = null
}

variable "frontend_endpoints" {
  description = "A list of frontend endpoints to configure."
  type = list(object({
    name                                    = string
    host_name                               = string
    session_affinity_enabled                = bool
    session_affinity_ttl_seconds            = number
    web_application_firewall_policy_link_id = string
  }))
  default = null
}

variable "routing_rules" {
  description = "A list of routing rules."
  type = list(object({
    name               = string
    frontend_endpoints = list(string)
    accepted_protocols = list(string)
    patterns_to_match  = list(string)
    enabled            = bool
    forwarding_configuration = object({
      backend_pool_name                     = string
      cache_enabled                         = bool
      cache_use_dynamic_compression         = bool
      cache_query_parameter_strip_directive = string
      cache_query_parameters                = list(string)
      cache_duration                        = number
      custom_forwarding_path                = string
      forwarding_protocol                   = string
    })
    redirect_configuration = object({
      custom_host         = string
      redirect_protocol   = string
      redirect_type       = string
      custom_fragment     = string
      custom_path         = string
      custom_query_string = string
    })
  }))
  default = null
}

variable "tags" {
  description = "A mapping of tags associated to the resource."
  type        = map(string)
  default = {
    "terraform" = "true"
  }
}
