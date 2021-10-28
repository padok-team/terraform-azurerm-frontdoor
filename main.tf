
resource "azurerm_frontdoor" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  dynamic "backend_pool" {
    for_each = var.backend_pools
    content {
      name = backend_pool.value["name"]

      dynamic "backend" {
        for_each = backend_pool.value["backends"]
        content {
          enabled     = backend.value["enabled"]
          address     = backend.value["address"]
          host_header = backend.value["host_header"]
          http_port   = backend.value["http_port"]
          https_port  = backend.value["https_port"]
          priority    = backend.value["priority"]
          weight      = backend.value["weight"]
        }
      }

      load_balancing_name = backend_pool.value["load_balancing_name"]
      health_probe_name   = backend_pool.value["health_probe_name"]
    }
  }

  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pool_health_probes
    content {
      name                = backend_pool_health_probe.value["name"]
      enabled             = backend_pool_health_probe.value["enabled"]
      path                = backend_pool_health_probe.value["path"]
      protocol            = backend_pool_health_probe.value["protocol"]
      probe_method        = backend_pool_health_probe.value["probe_method"]
      interval_in_seconds = backend_pool_health_probe.value["interval_in_seconds"]
    }
  }

  dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pool_load_balancings
    content {
      name                            = backend_pool_load_balancing.value["name"]
      sample_size                     = backend_pool_load_balancing.value["sample_size"]
      successful_samples_required     = backend_pool_load_balancing.value["successful_samples_required"]
      additional_latency_milliseconds = backend_pool_load_balancing.value["additional_latency_milliseconds"]
    }
  }

  backend_pools_send_receive_timeout_seconds   = var.backend_pools_send_receive_timeout_seconds
  enforce_backend_pools_certificate_name_check = var.enforce_backend_pools_certificate_name_check
  load_balancer_enabled                        = var.load_balancer_enabled
  friendly_name                                = var.friendly_name

  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoints
    content {
      name                                    = frontend_endpoint.value["name"]
      host_name                               = frontend_endpoint.value["host_name"]
      session_affinity_enabled                = frontend_endpoint.value["session_affinity_enabled"]
      session_affinity_ttl_seconds            = frontend_endpoint.value["session_affinity_ttl_seconds"]
      web_application_firewall_policy_link_id = frontend_endpoint.value["web_application_firewall_policy_link_id"]
    }
  }

  dynamic "routing_rule" {
    for_each = var.routing_rules
    content {
      name               = routing_rule.value["name"]
      frontend_endpoints = routing_rule.value["frontend_endpoints"]
      accepted_protocols = routing_rule.value["accepted_protocols"]
      patterns_to_match  = routing_rule.value["patterns_to_match"]
      enabled            = routing_rule.value["enabled"]

      dynamic "forwarding_configuration" {
        for_each = routing_rule.value.forwarding_configuration != null ? [1] : []
        content {
          backend_pool_name             = routing_rule.value.forwarding_configuration["backend_pool_name"]
          cache_enabled                 = routing_rule.value.forwarding_configuration["cache_enabled"]
          cache_use_dynamic_compression = routing_rule.value.forwarding_configuration["cache_use_dynamic_compression"]
          cache_query_parameters        = routing_rule.value.forwarding_configuration["cache_query_parameters"]
          cache_duration                = routing_rule.value.forwarding_configuration["cache_duration"]
          custom_forwarding_path        = routing_rule.value.forwarding_configuration["custom_forwarding_path"]
          forwarding_protocol           = routing_rule.value.forwarding_configuration["forwarding_protocol"]
        }
      }

      dynamic "redirect_configuration" {
        for_each = routing_rule.value.redirect_configuration != null ? [1] : []
        content {
          custom_host         = routing_rule.value.redirect_configuration["custom_host"]
          redirect_protocol   = routing_rule.value.redirect_configuration["redirect_protocol"]
          redirect_type       = routing_rule.value.redirect_configuration["redirect_type"]
          custom_fragment     = routing_rule.value.redirect_configuration["custom_fragment"]
          custom_path         = routing_rule.value.redirect_configuration["custom_path"]
          custom_query_string = routing_rule.value.redirect_configuration["custom_query_string"]
        }
      }
    }
  }

  tags = var.tags
}