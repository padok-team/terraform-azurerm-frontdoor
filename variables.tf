terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

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
    enabled             = optional(bool)
    path                = string
    probe_method        = optional(string)
    protocol            = optional(string)
    interval_in_seconds = optional(number)
  }))
}

variable "backend_pool_health_probes_generic_protocol" {
  description = "The default value for the protocol parameter of the generic backend pool health probes."
  type        = string
  default     = "Https"
}
variable "backend_pool_health_probes_generic_probe_method" {
  description = "The default value for the probe_method parameter of the generic backend pool health probes."
  type        = string
  default     = "HEAD"
}
variable "backend_pool_health_probes_generic_interval_in_seconds" {
  description = "The default value for the interval_in_seconds parameter of the generic backend pool health probes."
  type        = number
  default     = 120
}
variable "backend_pool_health_probes_generic_enabled" {
  description = "The default value for the protocol parameter of the generic backend pool health probes."
  type        = bool
  default     = true
}

variable "backend_pool_load_balancings" {
  description = "A list of the backend pool load balancing."
  type = list(object({
    name                            = string
    sample_size                     = optional(number)
    successful_samples_required     = optional(number)
    additional_latency_milliseconds = optional(number)
  }))
}

variable "backend_pool_load_balancings_generic_sample_size" {
  description = "The default value for the sample_size parameter in the generic load backend pool load balancing."
  type        = number
  default     = 4
}
variable "backend_pool_load_balancings_generic_successful_samples_required" {
  description = "The default value for the successful_samples_required parameter in the generic load backend pool load balancing."
  type        = number
  default     = 2
}
variable "backend_pool_load_balancings_generic_additional_latency_milliseconds" {
  description = "The default value for the additional_latency_milliseconds parameter in the generic load backend pool load balancing."
  type        = number
  default     = 0
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
    name                                    = optional(string)
    host_name                               = string
    session_affinity_enabled                = optional(bool)
    session_affinity_ttl_seconds            = optional(number)
    web_application_firewall_policy_link_id = optional(string)
  }))
  default = null
}

variable "session_affinity_enabled_generic" {
  type        = bool
  description = "Value of session_affinity_enable for all generic frontend_endpoints."
  default     = false
}

variable "session_affinity_ttl_seconds_generic" {
  type        = number
  description = "Value of session_affinity_ttl_seconds for all generic frontend_endpoints."
  default     = 0
}

variable "web_application_firewall_policy_link_id_generic" {
  type        = string
  description = "Value of web_application_firewall_policy_link_id for all generic frontend_endpoints."
  default     = null
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
