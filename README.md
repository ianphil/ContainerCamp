# Container Camp #
The official un-official container camp used to build out containerized applications on Azure.

We assume you have an Azure Subscription... If you don't, break out your Microsoft Account (aka LiveID, Hotmail account, etc) and pick one of these options:

* [Free $200/One Month Trial](https://azure.microsoft.com/en-us/free/) – $200 credit for use in 30 days.
* [Visual Studio Dev Essentials Program](https://www.visualstudio.com/dev-essentials/?campaign=VSBlog_AzureXamAnnoucement_VSDE) – Comes with $25 a month of Azure credit for 12 months.
* [IT Pro Cloud Essentials Program](https://www.microsoft.com/itprocloudessentials/en-US) – Also comes with $25 a month of Azure credit for 12 months.


## Lab One: Create an Azure Linux Jumpbox  ##
In this setup, you will create a linux jumpbox VM in Azure using the Azure Portal, install the Azure cli, and install docker on the vm.

- Setup Step 1: [Deploy a simple Linux VM jumpbox using portal](setup/deploy-linuxjumpbox.md)
- Setup Step 2: [Login to Azure CLI](setup/xplat-cli-login.md)
- Setup Step 3: [Install Docker on the jumpbox](setup/azdockerinstall.md)

## Lab Two: Deploy some containers on your jumpbox ##

* [Use the Jumpbox to deploy containers](labtwo/deploy-docker-vm.md)

## Lab Three: Configure a Windows Container Host ##
In this lab you will build a Windows 2016 Server TP5 Container Host and deploy Windows containers.

* [Windows Containers on Windows Server](labthree/windows-containers.md)

## Lab Four: Setup Docker Swarm and Deploy Some Containers ##
In this lab you will deploy Docker with swarm mode, using an acs-machine template to deploy to Azure. Once you have a swarm cluster you will deploy some things to it...

* [Deploy a Swarm Mode cluster](labfour/deploy-docker-swarm.md)

<!-- ## Lab Five: Setup Azure Container Service ## -->
## Lab Five: Deploy multicontainer applications
* [Deploy multicontainer applications](labfive/multiapp.md)




<!--
* [Deploy Azure Container Service](labfive/deploy-acs.md)
* [Connect and Use ACS](labfive/connect-acs.md)
-->