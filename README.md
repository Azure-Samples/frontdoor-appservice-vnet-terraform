# Project Name

This project provides a sample terraform script for provisioning a WAF enabled frontdoor with backend pools set with an existing app service, routing rules with  caching config exposed on a private vnet

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
terraform plan
terraform apply

```

## Demo

### Validate Frontdoor from the Azure Portal

- [ ] Private VNET with specified name is created

- [X] Resource group with specified name is created

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
    - [ ] Backend host voting app

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

- [ ] Frontdoor created with Https Redirect Routing Rule
    - [ ] Redirect type to "Found"
    - [ ] Redirect protocol "HttpsOnly"

## Resources

- [Frontdoor Terraform](https://www.terraform.io/docs/providers/azurerm/r/frontdoor.html#example-usage)
- [Azure Frontdoor](https://azure.microsoft.com/en-us/services/frontdoor/)