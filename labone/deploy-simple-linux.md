# A Very Simple Deployment of a Linux VM #
Let's set the stage, we want to deploy a VM into Azure. This VM will be a basic install of Ubuntu 14.04 without docker. 

1. Browse the [Azure Quick Start Template Repo](https://github.com/Azure/azure-quickstart-templates)
	1. Yea there is a lot there...
2. Have a look at the [101-vm-simple-linux](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-simple-linux) folder.
	1. There is a azuredeploy.json file. It descibes the resources we want to create. It also has parameters for things like username and password.
	2. There is a azuredeploy.parameters.json file that contains the parameters to pass to the template. Customers use multiple param files to create different environments like dev, test, prod. **We will not use this for the lab.**


## Create Resource Group ##
A resource group is a grouping of Azure resouces that can be managed and secured as a single unit. Read "I can delete every resource in a resource group by deleting the resource group"... kind of scary.

**Create a resource group from the Azure-CLI:**

    az group create --name {RESOURCE GROUP NAME} -l eastus

> Replace {RESOURCE GROUP NAME} with whatever you like. The "eastus" at the end is the data center location. There are more than  22+ locations....

## Deploy the VM ##
Now it's time to create a VM... 

**Deploy an ARM Template using the Azure Portal:**

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-vm-simple-linux%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


## SSH to your new Linux Box ##
From the command line we'll ssh to the server, feel free to poke around once connected.

    ssh username@DNS-LABEL-YOU-CREATED.eastus.cloudapp.azure.com

> On Windows and need SSH? [Download Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) or try [Bitvise SSH](https://www.bitvise.com/ssh-client-download)

# Alternative/Optional:  Deploy a VM using the CLI

This command creates an Ubuntu VM:
```
 az vm create -n MyVm -g {resourcegroupname} --image UbuntuLTS --admin-username adminuser --generate-ssh-keys --verbose
 az vm list
 az vm list-ip-addresses
```

# Delete the Resource Group ##
This command will remove everything you just created!

    az group delete --name {RESOURCE GROUP NAME} --no-wait
