# Install the Azure CLI

Quickly install the Azure Command-Line Interface (Azure CLI) to use a set of open-source shell-based commands for creating and managing resources in Microsoft Azure. Use one of the provided installer packages to install the Azure CLI on your operating system, install the CLI using Node.js and **npm**, or install the Azure CLI as a container in a Docker host. For more options and background, see the project repository on [GitHub](https://github.com/azure/azure-xplat-cli).

## Use an installer
The following installer packages are available:

* [Windows installer][windows-installer]

* [OS X installer][mac-installer]

* [Linux installer][linux-installer]

## Install and use Node.js and npm

If Node.js is already installed on your system, use the following command to install the Azure CLI:

	npm install azure-cli -g

## Use a Docker container

In a Docker host, run:

    docker run -it microsoft/azure-cli

[mac-installer]: http://go.microsoft.com/fwlink/?LinkId=252249
[windows-installer]: http://aka.ms/webpi-azure-cli
[linux-installer]: http://go.microsoft.com/fwlink/?linkid=253472
