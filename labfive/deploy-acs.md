# Setup Azure Container Service 
In this lab we'll look at Microsoft Azure's Container as a Service solution called: Azure Container Service (ACS).

## Create a service by using the Azure CLI

To create an instance of Azure Container Service by using the command line, you need an Azure subscription. If you don't have one, then you can sign up for a [free trial](http://azure.microsoft.com/pricing/free-trial/?WT.mc_id=AA4C1C935). You also need to have installed and configured the Azure CLI.

To deploy a DC/OS or Docker Swarm cluster, select one of the following templates from GitHub. Note that both of these templates are the same, with the exception of the default orchestrator selection.

* [DC/OS template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-mesos)
* [Swarm template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-swarm)

Next, make sure that the Azure CLI has been connected to an Azure subscription. You can do this by using the following command:

```bash
azure account show
```
If an Azure account is not returned, use the following command to sign the CLI in to Azure.

```bash
azure login -u user@domain.com
```

Next, configure the Azure CLI tools to use Azure Resource Manager.

```bash
azure config mode arm
```

Create an Azure Resource Group and Container Service cluster with the following command, where:

- **RESOURCE_GROUP** is the name of the Resource Group you want to use for this service.
- **LOCATION** is the Azure region where the Resource Group and Azure Container Service deployment will be created.
- **TEMPLATE_URI** is the location of the deployment file. **Note** - this must be the RAW file, not a pointer to the GitHub UI. To find this URL select the azuredeploy.json file in GitHub and click the RAW button:

> Note - when running this command, the shell will prompt you for deployment parameter values.
 
```bash
# sample deployment

azure group create -n RESOURCE_GROUP DEPLOYMENT_NAME -l LOCATION --template-uri TEMPLATE_URI
```

### Provide template parameters

This version of the command requires you to define parameters interactively. If you want to provide parameters, such as a JSON-formatted string, you can do so by using the `-p` switch. For example:

 ```bash
 # sample deployment

azure group deployment create RESOURCE_GROUP DEPLOYMENT_NAME --template-uri TEMPLATE_URI -p '{ "param1": "value1" … }'
 ```

Alternatively, you can provide a JSON-formatted parameters file by using the `-e` switch:

 ```bash
 # sample deployment

azure group deployment create RESOURCE_GROUP DEPLOYMENT_NAME --template-uri TEMPLATE_URI -e PATH/FILE.JSON
 ```

To see an example parameters file named `azuredeploy.parameters.json`, look for it with the Azure Container Service templates in GitHub.