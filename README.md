# Project Name

This project provides a sample terraform script for provisioning a WAF enabled frontdoor with backend pools set with an existing Azure App service, routing rules with  caching config exposed on a private vnet

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Installation

``` shell
git clone https://github.com/Azure-Samples/frontdoor-appservice-vnet-terraform.git
cd frontdoor-appservice-vnet-terraform
```

### Quickstart

``` shell
az login
az account set -s <subscription_id>

terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

```

## Demo

### Validate Frontdoor from the Azure Portal

- [X] Resource group with specified name is created

- [X] Provision Voting App from https://github.com/Azure-Samples/azure-voting-app-redis
    - [X] Provision Voting App from docker-compose.yaml
    - [X] Limit Access to the Voting App from frontdoor only
    
- [X] Frontdoor Global WAF is created with following config
    - [X] Prevention Policy Settings 
    - [X] Managed Rules  as DefaultRuleSet_1.0 and Microsoft_BotManagerRuleSet_1.0
    - [X] Custom Rules to deny traffic to non allowable IPs

- [X] Frontdoor is created with following config
    - [X] Frontdoor endpoint is created
    - [X] SESSION AFFINITY disabled
    - [X] WAF enabled and associated with created WAF
        
- [X] Backendpool is created
    - [X] Backend host name bing.com
    - [X] HealthProbe enabled with HTTPS protocol
    - [X] Load balancing set with default config

- [X] Frontdoor created with Forwarding Routing Rule
    - [X] Status "enabled"
    - [X] Accepted Protocol HTTPS
    - [X] Pattern to match a /*
    - [X] Route Type Forward
    - [X] Backendpool is set
    - [X] Forwarding Protocol HttpsOnly request
    - [X] URL Rewrite disabled
    - [X] Caching enabled and query string behavior is set to "Cache Every Unique URL"
    - [X] Dynamic compression "enables"
    - [X] Use default cache duration "Yes"

- [X] Frontdoor created with Https Redirect Routing Rule
    - [X] Redirect type to "Found"
    - [X] Redirect protocol "HttpsOnly"

## GitHub Issues Created

- [Feature Request: Support for Config Backend Host Type in backendpool to support "Public IP Address"](https://github.com/terraform-providers/terraform-provider-azurerm/issues/8809)
- [Bug : Unable to get multiple routing rules working with the same backend pool](https://github.com/terraform-providers/terraform-provider-azurerm/issues/8858)
- [Frontdoor cannot be created in VNET needs publicly resolvable IP Address](https://github.com/MicrosoftDocs/azure-docs/issues/17639)

## Resources

- [Frontdoor Terraform](https://www.terraform.io/docs/providers/azurerm/r/frontdoor.html#example-usage)
- [Azure Frontdoor](https://azure.microsoft.com/en-us/services/frontdoor/)