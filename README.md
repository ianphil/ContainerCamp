# ContainerCamp #

The official un-official Container Camp by Microsoft. This is used to build out containerized applications on Azure and Windows.

> We assume you have an Azure Subscription...

## Azure Setup:  ##
This will setup cmd line access to Azure and works on OSX, Linux, even Windows.... At the bottom of setup step one, there is a Docker Image that will run the CLI in a container. Don't you think that's the right choice for this...

* Setup Step One 	- [Install Azure CLI](setup/xplat-cli-install.md)
* Setup Step Two 	- [Login to Azure CLI](setup/xplat-cli-login.md)
* Setup Step Three 	- [Switch Azure CLI to ARM Mode](setup/xplat-cli-arm.md)

## Lab One: Getting Familiar with Azure Resource Manager ##
This lab will get you familiar with using the Azure CLI for deploying resources to Azure. We'll use Azure Resource Manager (ARM) Templates to describe what we want created in Azure. For More information about ARM and ARM Templates see: [Azure Resource Manager Overview](labone/arm-overview.md).

* [Deploy a simple Linux VM using the Quick Start Templates and the Azure CLI](labone/deploy-simple-linux.md)