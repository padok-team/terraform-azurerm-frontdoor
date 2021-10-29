terraform {
  required_version = ">= 0.13.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.82.0"
    }
  }
}
provider "azurerm" {
  features {}
}



module "resource_group" {
  source   = "git@github.com:padok-team/terraform-azurerm-resource-group.git?ref=v0.0.2"
  name     = "example_rg"
  location = "West Europe"
}

# Create a resource group to deploy the frontdoor
module "rg_example" {
  source = "git@github.com:padok-team/terraform-azurerm-resource-group.git?ref=v0.0.2"


  name     = "frontdoor_example"
  location = "West Europe"

  tags = {
    terraform = "true"
    padok     = "library"
  }
}

module "frontdoor" {
  source = "git@github.com:padok-team/terraform-azurerm-frontdoor.git?ref=v0.0.1"

  name                = "padokexamplefrontdoor"
  resource_group_name = module.rg_example.this.name

  backend_pools = [{
    name = "example-backendpool"
    backends = [{
      enabled     = true
      address     = "padok.fr"
      host_header = "padok.fr"
      http_port   = 80
      https_port  = 443

      priority = null
      weight   = null
    }]
    load_balancing_name = "example-load-balancing"
    health_probe_name   = "example-health-probe"
  }]

  backend_pool_health_probes = [{
    name    = "example-health-probe"
    enabled = false

    path                = null
    protocol            = null
    probe_method        = null
    interval_in_seconds = null
  }]

  backend_pool_load_balancings = [{
    name = "example-load-balancing"

    sample_size                     = null
    successful_samples_required     = null
    additional_latency_milliseconds = null
  }]

  enforce_backend_pools_certificate_name_check = false

  friendly_name = "MyExampleFrontDoor"

  frontend_endpoints = [{
    name      = "example-frontendendpoint"
    host_name = "padokexamplefrontdoor.azurefd.net"

    session_affinity_enabled                = null
    session_affinity_ttl_seconds            = null
    web_application_firewall_policy_link_id = null
  }]

  routing_rules = [{
    name               = "example-routingrule"
    frontend_endpoints = ["example-frontendendpoint"]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    enabled            = true
    forwarding_configuration = {
      backend_pool_name   = "example-backendpool"
      cache_enabled       = false
      forwarding_protocol = "MatchRequest"

      cache_use_dynamic_compression         = null
      cache_query_parameter_strip_directive = null
      cache_query_parameters                = null
      cache_duration                        = null
      custom_forwarding_path                = null
    }

    redirect_configuration = null
  }]

  tags = {
    terraform = "true"
    padok     = "library"
  }

}
