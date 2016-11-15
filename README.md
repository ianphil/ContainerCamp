# Container Camp #
The official un-official container camp used to build out containerized applications on Azure.

> We assume you have an Azure Subscription...

## Azure Setup:  ##
This will setup cmd line access to Azure and works on OSX, Linux, even Windows.... At the bottom of setup step one, there is a Docker Image that will run the CLI in a container. Don't you think that's the right choice for this...

* Setup Step One 	- [Install Azure CLI](setup/xplat-cli-install.md)
* Setup Step Two 	- [Login to Azure CLI](setup/xplat-cli-login.md)
* Setup Step Three 	- [Switch Azure CLI to ARM Mode](setup/xplat-cli-arm.md)
* Setup Step Four	- [Install Docker for Windows or Mac](https://www.docker.com/)

## Lab One: Getting Familiar with Azure Resource Manager ##
This lab will get you familiar with using the Azure CLI for deploying resources to Azure. We'll use Azure Resource Manager (ARM) Templates to describe what we want created in Azure. For More information about ARM and ARM Templates see: [Azure Resource Manager Overview](labone/arm-overview.md).

* [Deploy a simple Linux VM using the Quick Start Templates and the Azure CLI](labone/deploy-simple-linux.md)

## Lab Two: Run Docker on a VM in Azure ##
In this lab you will setup a VM like in labone, but it will have docker... We'll deploy nginx and hit the default website from a browser.

* [Deploy a Docker VM using the Quick Start Template](labtwo/deploy-docker-vm.md)

## Lab Three: Configure a Windows Container Host ##
In this lab you will build a Windows 2016 Server TP5 Container Host and deploy Windows containers.

* [Windows Containers on Windows Server](labthree/windows-containers.md)

## Lab Four: Setup Docker Swarm and Deploy Some Containers ##
In this lab you will deploy Docker with swarm mode, using docker-machine to deploy to Azure. Once you have a swarm you will deploy some things to it...

* [Deploy Docker using swarm mode](labfour/deploy-docker-swarm.md)

## OPTIONAL - Lab Five: Setup Azure Container Service ##
In this lab we'll look at Microsoft Azure's Container as a Service solution called: Azure Container Service (ACS).

* [Deploy Azure Container Service](labfive/deploy-acs.md)
* [Connect and Use ACS](labfive/connect-acs.md)