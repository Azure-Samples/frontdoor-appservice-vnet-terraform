# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = ">= 2.26"
  features {}
}

# Create Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_app_service_plan" "asp" {
  name                = "rocket-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}


resource "azurerm_app_service" "apsvc" {
  name                = "rocket-appservice"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "COMPOSE|${filebase64("docker-compose.yaml")}"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://mcr.microsoft.com",
    "DOCKER_REGISTRY_SERVER_USERNAME" = "",
    "DOCKER_REGISTRY_SERVER_PASSWORD" = "",
  }
}

resource "azurerm_frontdoor_firewall_policy" "demowafpolicy" {
  name                              = "demowafpolicy"
  resource_group_name               = azurerm_resource_group.rg.name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = "YmxvY2tlZCBieSBmcm9udGRvb3I="

  custom_rule {
    name                           = "allowip"
    enabled                        = true
    priority                       = 1
    rate_limit_duration_in_minutes = 1
    rate_limit_threshold           = 10
    type                           = "MatchRule"
    action                         = "Block"

    match_condition {
      match_variable     = "RemoteAddr"
      operator           = "IPMatch"
      negation_condition = true
      match_values       = ["98.207.35.44", "108.255.198.204", "71.36.63.214", "98.234.150.145" ]
    }
  }

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
  }
}

resource "azurerm_frontdoor" "rocketdemofd" {
  name                                         = "rocketdemofd"
  resource_group_name                          = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "rocketDemoRoutingRule1"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["rocketdemofd"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "rocketDemoBackendBing"
      cache_enabled = true
      cache_query_parameter_strip_directive = "StripNone"
      cache_use_dynamic_compression         = true  
    }

  }

  backend_pool_load_balancing {
    name = "rocketDemoLoadBalancingSettings1"

  }

  backend_pool_health_probe {
    name = "rocketDemoHealthProbeSetting1"
    protocol              = "Https"
  }

  backend_pool {
    name = "rocketDemoBackendBing"
    backend {
      host_header = "www.bing.com"
      address     = "www.bing.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "rocketDemoLoadBalancingSettings1"
    health_probe_name   = "rocketDemoHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "rocketdemofd"
    host_name                         = "rocketdemofd.azurefd.net"
    session_affinity_enabled          = false 
    session_affinity_ttl_seconds      = 0     
    custom_https_provisioning_enabled = false
    web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.demowafpolicy.id
  }
}