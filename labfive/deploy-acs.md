# Setup Azure Container Service 
In this lab we'll look at Microsoft Azure's Container as a Service solution called: Azure Container Service (ACS).

## Create a service by using the Azure CLI

To create an instance of Azure Container Service by using the command line, you need an Azure subscription. If you don't have one, then you can sign up for a [free trial](http://azure.microsoft.com/pricing/free-trial/?WT.mc_id=AA4C1C935). You also need to have installed and configured the Azure CLI.

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

## Alternative:  Create service by using the Azure Portal
Go to http://portal.azure.com, then click the "+", then "Containers", then "Azure Container Service".  
Then fill out the fields as above.
