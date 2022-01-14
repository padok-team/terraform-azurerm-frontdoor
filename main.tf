
resource "azurerm_frontdoor" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  ## Backend Pool represents the pool of backend servers to which the load balancer sends requests.
  dynamic "backend_pool" {
    for_each = var.backend_pools
    content {
      name = backend_pool.value["name"]

      ## Backend Address Pool represents a pool of backend IP addresses.
      ## This pool can be used for load balancing scenarios with multiple backends.
      ## For example, you can configure a pool of backend IP addresses to be load balanced to different
      ## IP addresses for each request.
      dynamic "backend" {
        for_each = backend_pool.value["backends"]
        content {
          enabled = backend.value["enabled"]
          ## address is the IP address of the backend server.
          address = backend.value["address"]
          ## Header is a list of HTTP headers to send to the backend servers.
          # header_name = backend.value["header_name"]
          ## Header value is the value of the HTTP header specified in headerName.
          # header_value = backend.value["header_value"]
          ## Host Header is the host header value sent to the backend servers.
          host_header = backend.value["host_header"]
          ## Http Port is the port to listen on for HTTP requests.
          http_port = backend.value["http_port"]
          ## Https Port is the port to listen on for HTTPS requests.
          https_port = backend.value["https_port"]
          ## Priority is the priority of the backend server in the backend pool.
          priority = backend.value["priority"]
          ## Weight is the weight of the backend server in the backend pool.
          weight = backend.value["weight"]
        }
      }
      ## Load Balancing name is the name of the load balancing rule.
      load_balancing_name = backend_pool.value["load_balancing_name"]
      ## Health Probe Name is the name of the health probe.
      health_probe_name = backend_pool.value["health_probe_name"]
    }
  }

  ## Backend Pool Health Probe represents the health probe settings to be used for the backend pool.
  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pool_health_probes
    content {
      ## Name is the name of the health probe.
      name = backend_pool_health_probe.value["name"]
      ## Enabled is whether the health probe is enabled.
      enabled = backend_pool_health_probe.value["enabled"]
      ## Path is the path to use for the health probe. For example, /ping.
      path = backend_pool_health_probe.value["path"]
      ## Protocol is the protocol to use for the health probe. For example Http.
      protocol = backend_pool_health_probe.value["protocol"]
      ## Probre Method is the HTTP method to use for the health probe. For example, HttpGet.
      probe_method = backend_pool_health_probe.value["probe_method"]
      ## Interval in seconds between health probes to the backend servers. For example, 10.
      interval_in_seconds = backend_pool_health_probe.value["interval_in_seconds"]
    }
  }

  ## Backend Pool Load Balancing Rule represents the load balancing settings to be used for the backend pool.
  dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pool_load_balancings
    content {
      name = backend_pool_load_balancing.value["name"]
      ## Sample Size is the number of samples to consider for determining the state of the backend host. For example, 3.
      sample_size = backend_pool_load_balancing.value["sample_size"]
      ## Successful samples required to mark a host up. For example, 2.
      successful_samples_required = backend_pool_load_balancing.value["successful_samples_required"]
      ## Additional Latency Milliseconds is the additional latency in milliseconds for probes to this backend host. For example, 10.
      additional_latency_milliseconds = backend_pool_load_balancing.value["additional_latency_milliseconds"]
    }
  }

  ## Backend Pools send receive timeout seconds is the number of seconds to wait before timing out a request to a backend server.
  backend_pools_send_receive_timeout_seconds = var.backend_pools_send_receive_timeout_seconds
  ## Enforce Backend pools certificate name check is whether to enforce the backend pool certificate name check. It is usefull when the backend pool uses a self-signed certificate.
  enforce_backend_pools_certificate_name_check = var.enforce_backend_pools_certificate_name_check
  ## Load balancer enabled specifies if the load balancer should be enabled
  load_balancer_enabled = var.load_balancer_enabled
  ## Friendly Name
  friendly_name = var.friendly_name

  ## Frontend Endpoints represents the frontend endpoints to be used for the load balancer.
  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoints
    content {
      ## Name represents the name of the frontend endpoint.
      name = frontend_endpoint.value["name"]
      ## Host Name is the host name of the frontend endpoint. For example, myapp.azurewebsites.net.
      host_name = frontend_endpoint.value["host_name"]
      ## Session affinity configures how to use session affinity when routing requests to backend servers. For example, When enabled, requests from the same client IP address but from different user agents will be routed to the same backend server.
      session_affinity_enabled = frontend_endpoint.value["session_affinity_enabled"]
      ## Session affinity timeout in seconds specifies the duration (in seconds) within which a session must be observed before it times out. For example, 3600.
      session_affinity_ttl_seconds = frontend_endpoint.value["session_affinity_ttl_seconds"]
      ## Web application firewall policy link id is the id of the web application firewall policy to be used for the frontend endpoint. It should be in the form of /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/ApplicationGateways/{applicationGatewayName}/webApplicationFirewallPolicies/{policyName}. More info on Application Gateway can be found at https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq.
      web_application_firewall_policy_link_id = frontend_endpoint.value["web_application_firewall_policy_link_id"]
    }
  }

  ## Routing Rule represents the routing rule to be used for the load balancer. It is used to route traffic to the backend pool.
  dynamic "routing_rule" {
    for_each = var.routing_rules
    content {
      ## Name is the name of the routing rule.
      name = routing_rule.value["name"]
      ## Frontend Endpoint Name is the name of the frontend endpoint. For example, myapp.azurewebsites.net.
      frontend_endpoints = routing_rule.value["frontend_endpoints"]
      ## Accepted Protocols is the list of accepted protocols. For example, Http.
      accepted_protocols = routing_rule.value["accepted_protocols"]
      ## Patterns to match against the request URL path. For example, /catalog/*.
      patterns_to_match = routing_rule.value["patterns_to_match"]
      enabled           = routing_rule.value["enabled"]

      ## Forwarding Configuration represents the forwarding configuration to be used for the routing rule.
      dynamic "forwarding_configuration" {
        for_each = routing_rule.value.forwarding_configuration != null ? [1] : []
        content {
          ## Backend Pool Name is the name of the backend pool.
          backend_pool_name = routing_rule.value.forwarding_configuration["backend_pool_name"]
          ## Cache Enabled specifies whether to enable caching. Cache settings are specified in the Cache Configuration.
          cache_enabled = routing_rule.value.forwarding_configuration["cache_enabled"]
          ## Use Dynamic Compression specifies whether to enable dynamic compression. Dynamic compression is enabled by default. It is useful in scenarios where the content length is unknown.
          cache_use_dynamic_compression = routing_rule.value.forwarding_configuration["cache_use_dynamic_compression"]
          ## Cache query parameters
          cache_query_parameters = routing_rule.value.forwarding_configuration["cache_query_parameters"]
          ## Cache duration in seconds specifies the duration (in seconds) during which the response is cached. For example, 3600.
          cache_duration = routing_rule.value.forwarding_configuration["cache_duration"]
          ## Custom Forwarding Path is the path to use for forwarding requests to the backend pool. If not specified, the request path will be used. For example, /catalog.
          custom_forwarding_path = routing_rule.value.forwarding_configuration["custom_forwarding_path"]
          ## Forwarding Protocol is the protocol to use for forwarding requests to the backend pool. For example, Http. It can be Http or Https.
          forwarding_protocol = routing_rule.value.forwarding_configuration["forwarding_protocol"]
        }
      }


      ## Redirect Configuration represents the redirect configuration to be used for the routing rule.
      dynamic "redirect_configuration" {
        for_each = routing_rule.value.redirect_configuration != null ? [1] : []
        content {
          ## Custom host is the host to use for redirects. If not specified, the host in the incoming request will be used. For example, myapp.azurewebsites.net.
          custom_host = routing_rule.value.redirect_configuration["custom_host"]
          ## Redirect Protocol is the protocol to use for redirects. For example, Http. It can be Http or Https.
          redirect_protocol = routing_rule.value.redirect_configuration["redirect_protocol"]
          ## Redirect Type is the type of redirect to use. For example, Permanent or Found.
          redirect_type = routing_rule.value.redirect_configuration["redirect_type"]
          ## Custom Fragment is the fragment to add to the redirected URL. For example, #top. If not specified, no fragment is added.
          custom_fragment = routing_rule.value.redirect_configuration["custom_fragment"]
          ## Custom path is the path to use for redirects. If not specified, the path of the incoming request is used. For example, /catalog.
          custom_path = routing_rule.value.redirect_configuration["custom_path"]
          ## Custom Query String is the query string to add to the redirected URL. For example, fields=name,price. If not specified, no query string is added.
          custom_query_string = routing_rule.value.redirect_configuration["custom_query_string"]
        }
      }
    }
  }

  ## Tags represents the tags to be assigned to the load balancer.
  tags = var.tags
}
