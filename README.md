# AZURE FRONTDOOR Terraform module

Terraform module which creates **FRONTDOOR** resources on **AZURE**.

## User Stories for this module

- AAOPS I can handle the incoming trafic to Azure
- AAOPS I can enforce HTTP to HTTPS redirections

## Usage

```hcl

module "frontdoor" {
  source = "git@github.com:padok-team/terraform-azurerm-frontdoor.git?ref=v0.1.0"

  name                = "padokexamplefrontdoor"
  resource_group_name = <your resource group name>

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

```

## Examples

- [Frontdoor redirecting to padok.fr](examples/frontdoor_basic_example/main.tf)
- [Frontdoor with HTTP to HTTPS redirection](examples/frontdoor_with_https_redirection/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_pool_health_probes"></a> [backend\_pool\_health\_probes](#input\_backend\_pool\_health\_probes) | A list of the backend pool health probes. | <pre>list(object({<br>    name                = string<br>    enabled             = bool<br>    path                = string<br>    protocol            = string<br>    probe_method        = string<br>    interval_in_seconds = number<br>  }))</pre> | n/a | yes |
| <a name="input_backend_pool_load_balancings"></a> [backend\_pool\_load\_balancings](#input\_backend\_pool\_load\_balancings) | A list of the backend pool load balancing. | <pre>list(object({<br>    name                            = string<br>    sample_size                     = number<br>    successful_samples_required     = number<br>    additional_latency_milliseconds = number<br>  }))</pre> | n/a | yes |
| <a name="input_backend_pools"></a> [backend\_pools](#input\_backend\_pools) | A list of backend pools. | <pre>list(object({<br>    name = string<br>    backends = list(object({<br>      enabled     = bool<br>      address     = string<br>      host_header = string<br>      http_port   = number<br>      https_port  = number<br>      priority    = number<br>      weight      = number<br>    }))<br>    load_balancing_name = string<br>    health_probe_name   = string<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Front Door. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Frontdoor should be created. | `string` | n/a | yes |
| <a name="input_backend_pools_send_receive_timeout_seconds"></a> [backend\_pools\_send\_receive\_timeout\_seconds](#input\_backend\_pools\_send\_receive\_timeout\_seconds) | Timeout on forwarding request to the backend. | `number` | `60` | no |
| <a name="input_enforce_backend_pools_certificate_name_check"></a> [enforce\_backend\_pools\_certificate\_name\_check](#input\_enforce\_backend\_pools\_certificate\_name\_check) | Enforce certificate name check on HTTPS for all backend pools. | `bool` | `true` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | A friendly name for the Frontdoor. | `string` | `null` | no |
| <a name="input_frontend_endpoints"></a> [frontend\_endpoints](#input\_frontend\_endpoints) | A list of frontend endpoints to configure. | <pre>list(object({<br>    name                                    = string<br>    host_name                               = string<br>    session_affinity_enabled                = bool<br>    session_affinity_ttl_seconds            = number<br>    web_application_firewall_policy_link_id = string<br>  }))</pre> | `null` | no |
| <a name="input_load_balancer_enabled"></a> [load\_balancer\_enabled](#input\_load\_balancer\_enabled) | Should the Frontdoor load balancer be enabled ? | `bool` | `true` | no |
| <a name="input_routing_rules"></a> [routing\_rules](#input\_routing\_rules) | A list of routing rules. | <pre>list(object({<br>    name               = string<br>    frontend_endpoints = list(string)<br>    accepted_protocols = list(string)<br>    patterns_to_match  = list(string)<br>    enabled            = bool<br>    forwarding_configuration = object({<br>      backend_pool_name                     = string<br>      cache_enabled                         = bool<br>      cache_use_dynamic_compression         = bool<br>      cache_query_parameter_strip_directive = string<br>      cache_query_parameters                = list(string)<br>      cache_duration                        = number<br>      custom_forwarding_path                = string<br>      forwarding_protocol                   = string<br>    })<br>    redirect_configuration = object({<br>      custom_host         = string<br>      redirect_protocol   = string<br>      redirect_type       = string<br>      custom_fragment     = string<br>      custom_path         = string<br>      custom_query_string = string<br>    })<br>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags associated to the resource. | `map(string)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this"></a> [this](#output\_this) | The Frontdoor resource. |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
