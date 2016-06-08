# Azure Resource Manager overview

The infrastructure for your application is typically made up of many components – maybe a virtual machine, storage account, and virtual network, or a web app, database, database server, and 3rd party services. You do not see these components as separate entities, instead you see them as related and interdependent parts of a single entity. You want to deploy, manage, and monitor them as a group. Azure Resource Manager enables you to work with the resources in your solution as a group. You can deploy, update or delete all of the resources for your solution in a single, coordinated operation. You use a template for deployment and that template can work for different environments such as testing, staging and production. Resource Manager provides security, auditing, and tagging features to help you manage your resources after deployment. 

## Resource groups

A resource group is a container that holds related resources for an application. The resource group could include all of the resources for an application, or only those resources that are logically grouped together. You can decide how you want to allocate resources to resource groups based on what makes the most sense for your organization.

There are some important factors to consider when defining your resource group:

1. All of the resources in your group should share the same lifecycle. You will deploy, update and delete them together. If one resource, such as a database server, needs to exist on a different deployment cycle it should be in another resource group.
2. Each resource can only exist in one resource group.
3. You can add or remove a resource to a resource group at any time.
4. You can move a resource from one resource group to another group.
4. A resource group can contain resources that reside in different regions.
5. A resource group can be used to scope access control for administrative actions.
6. A resource can be linked to a resource in another resource group when the two resources must interact with each other but they do not share the same lifecycle (for example, multiple apps connecting to a database).

## Resource providers

A resource provider is a service that supplies the resources you can deploy and manage through Resource Manager. Each resource provider offers REST API operations for working with the resources. For example, if you want to deploy an Azure Key Vault for storing keys and secrets, you will work with the **Microsoft.KeyVault** resource provider. This resource provider offers a resource type called **vaults** for creating the key vault, and a resource type called **vaults/secrets** for creating a secret in the key vault. You can learn about a resource provider by looking at it REST API operations, such as [Key Vault REST API operations](https://msdn.microsoft.com/library/azure/dn903609.aspx).

To deploy and manage your infrastructure, you will need to know details about the resource providers; such as, what resource types it offers, the version numbers of the REST API operations, the operations it supports, and the schema to use when setting the values of the resource type to create. 

## Template deployment

With Resource Manager, you can create a simple template (in JSON format) that defines deployment and configuration of your application. This template is known as a Resource Manager template and provides a declarative way to define deployment. By using a template, you can repeatedly deploy your application throughout the app lifecycle and have confidence your resources are deployed in a consistent state.

Within the template, you define the infrastructure for your app, how to configure that infrastructure, and how to publish your app code to that infrastructure. You do not need to worry about the order for deployment because Azure Resource Manager analyzes dependencies to ensure resources are created in the correct order.

When you create a solution from the Marketplace, the solution automatically includes a deployment template. You do not have to create your template from scratch because you can start with the template for your solution and customize it to meet your specific needs. You can retrieve a template for an existing resource group by either exporting the current state of the resource group to a template, or viewing the template that was used for a particular deployment. Viewing the exported template is a helpful way to learn about the template syntax.

You do not have to define your entire infrastructure in a single template. Often, it makes sense to divide your deployment requirements into a set of targeted, purpose-specific templates. You can easily re-use these templates for different solutions. To deploy a particular solution, you create a master template that links all of the required templates.

You can also use the template for updates to the infrastructure. For example, you can add a new resource to your app and add configuration rules for the resources that are already deployed. If the template specifies creating a new resource but that resource already exists, Azure Resource Manager performs an update instead of creating a new asset. Azure Resource Manager updates the existing asset to the same state as it would be as new. Or, you can specify that Resource Manager delete any resources that are not specified in the template. 

You can specify parameters in your template to allow for customization and flexibility in deployment. For example, you can pass parameter values that tailor deployment for your test environment. By specifying the parameters, you can use the same template for deployment to all of your app’s environments.

Resource Manager provides extensions for scenarios when you need additional operations such as installing particular software that is not included in the setup. If you are already using a configuration management service, like DSC, Chef or Puppet, you can continue working with that service by using extensions.

Finally, the template becomes part of the source code for your app. You can check it in to your source code repository and update it as your app evolves. You can edit the template through Visual Studio.