# Setup Azure Container Service 
In this lab we'll look at Microsoft Azure's Container as a Service solution called: Azure Container Service (ACS).

## Create a service by using the Azure CLI

To create an instance of Azure Container Service by using the command line, you need an Azure subscription. If you don't have one, then you can sign up for a [free trial](http://azure.microsoft.com/pricing/free-trial/?WT.mc_id=AA4C1C935). You also need to have installed and configured the Azure CLI.

<<<<<<< HEAD
To deploy a DC/OS or Docker Swarm cluster, select one of the following templates from GitHub. Note that both of these templates are the same, with the exception of the default orchestrator selection.

* [DC/OS template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-dcos)
* [Swarm template](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-swarm)

=======
>>>>>>> 5920e8dbfbf2c677e1d86ec10f7a4c73f67dfad8
Next, make sure that the Azure CLI has been connected to an Azure subscription. You can do this by using the following command:

```bash
az account list
```
If an Azure account is not returned, use the following command to sign the CLI in to Azure.

```bash
az login
```

Create an Azure Resource Group and Container Service cluster with the following command, where:

```
az group create --name MySwarmRG -l eastus
az acs create -g MySwarmRG -n MySwarmService --orchestrator-type Swarm -l eastus --agent-vm-size Standard_D1  --generate-ssh-keys --verbose
```

<<<<<<< HEAD
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
=======
## Alternative:  Create service by using the Azure Portal
Go to http://portal.azure.com, then click the "+", then "Containers", then "Azure Container Service".  
Then fill out the fields as above.
>>>>>>> 5920e8dbfbf2c677e1d86ec10f7a4c73f67dfad8
