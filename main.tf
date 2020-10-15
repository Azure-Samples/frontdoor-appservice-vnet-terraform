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

/* Provision existing voting App from https://github.com/Azure-Samples/azure-voting-app-redis */
/* Limit access to the App Service from FrontDoor Only */

resource "azurerm_app_service" "apsvc" {
  name                = "rocket-appservice"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {   
    /* Provision voting App from https://github.com/Azure-Samples/azure-voting-app-redis */
    linux_fx_version = "COMPOSE|${filebase64("docker-compose.yaml")}"
    /* App Service access limited to FrontDoor Only */

    ip_restriction = [
      {
        ip_address                = "147.243.0.0/16",
        virtual_network_subnet_id = null
        subnet_id                 = null
        name                      = "allowfrontdooripv4"
        description               = "allowfrontdooripv4"
        priority                  = 300
        action                    = "Allow"
      },{
        ip_address                = "2a01:111:2050::/44",
        virtual_network_subnet_id = null
        subnet_id                 = null
        name                      = "allowfrontdooripv6"
        description               = "allowfrontdooripv6"
        priority                  = 350
        action                    = "Allow"
      },{
        ip_address                = "168.63.129.16/32",
        virtual_network_subnet_id = null
        subnet_id                 = null
        name                      = "azureinfrasvcstart"
        description               = "azureinfrasvcstart"
        priority                  = 400
        action                    = "Allow"
      },{
        ip_address                = "169.254.169.254/32",
        virtual_network_subnet_id = null
        subnet_id                 = null
        name                      = "azureinfrasvcend "
        description               = "azureinfrasvcend"
        priority                  = 450
        action                    = "Allow"
      }]
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL" = "https://mcr.microsoft.com",
  }
}

resource "azurerm_frontdoor_firewall_policy" "demowafpolicy" {
  name                              = "demowafpolicy"
  resource_group_name               = azurerm_resource_group.rg.name
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  custom_block_response_body        = "YmxvY2tlZCBieSBmcm9udGRvb3I="

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
      backend_pool_name   = "rocketDemoBackendVoting"
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
    name = "rocketDemoBackendVoting"
    backend {
      host_header = "rocket-appservice.azurewebsites.net"
      address     = "rocket-appservice.azurewebsites.net"
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