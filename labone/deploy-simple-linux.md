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

    azure group create {RESOURCE GROUP NAME} eastus

> Replace {RESOURCE GROUP NAME} with whatever you like. The "eastus" at the end is the data center location. There something like 22+ DCs now...

## Deploy the VM ##
Now it's time to create a VM... 

**Deploy an ARM Template using the Azure-CLI:**

    azure group deployment create {RESOURCE GROUP NAME} {DEPLOYMENT NAME} --template-uri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/101-vm-simple-linux/azuredeploy.json

> Replace {RESOURCE GROUP NAME} with the resource group name you just created.

> Replace {DEPLOYMENT NAME} with whatever you like.

This command creates a deployment with the resource manager and passes the URI of the Linux template we just reviewed. It will also prompt you for the following parameters:

1. Username (don't use "admin")
2. Password (needs to be more than 8 chars and be complex)
3. DNS Label (this will be the dns prefix used to connect to the box)
4. Storage Account Name (blob storage for VM Disks)

## SSH to your new Linux Box ##
From the command line we'll ssh to the server, feel free to poke around once connected.

    ssh username@DNS-LABLE-YOU-CREATED.eastus.cloudapp.azure.com

> On Windows and need SSH? [Download Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).

## Delete the Resource Group ##
This command will remove everything you just created!

    azure group delete {RESOURCE GROUP NAME} -q