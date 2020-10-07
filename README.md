# Project Name

(short, 1-3 sentenced, description of the project)

## Features

This project framework provides the following features:

* Terraform template with Azure Front Door
* Feature 2
* ...

## Getting Started

### Prerequisites

(ideally very short, if any)

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Installation

(ideally very short)

- npm install [package name]
- mvn install
- ...

### Quickstart
There are [different ways](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html) to authenticate with the Azure provider via Terraform. This example uses a Service Principal with a Client Secret to authenticate. 

1. git clone [repository clone url]
2. cd [respository name]
3. az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"
4. Use the values from step 3 to create these environment variables to authenticate with the Azure provider.
```
export ARM_SUBSCRIPTION_ID=<subscription-id>
export ARM_CLIENT_ID=<app-id>
export ARM_CLIENT_SECRET=<password>
export ARM_TENANT_ID=<tenant-id>
```
5. terraform init
6. terraform plan -var-file="terraform.tfvars"
7. terraform apply -var-file="terraform.tfvars"


## Demo

A demo app is included to show how to use the project.

To run the demo, follow these steps:

(Add steps to start up the demo)

1.
2.
3.

## Resources

(Any additional resources or related projects)

- [Azure Provider: Authenticating using a Service Principal with a Client Secret](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)
- Link to similar sample
- ...
