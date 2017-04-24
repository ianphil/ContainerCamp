# A Very Simple Deployment of a Linux VM Running Docker #
Yup! It's time to get serious... In this lab we'll deploy a VM using an ARM Template. In this template is new resource called a VM extension. This extends our ability to deploy software or run scripts on the VM after it's created in Azure. There are many different VM extensions, but will be using the Docker VM Extension. The docker extension installs docker on the VM for us.

    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat(variables('vmName'),'/', variables('extensionName'))]",
      "apiVersion": "2015-05-01-preview",
      "location": "[resourceGroup().location]",
      "dependsOn": [
    "[concat('Microsoft.Compute/virtualMachines/', variables('vmName'))]"
      ],
      "properties": {
    "publisher": "Microsoft.Azure.Extensions",
    "type": "DockerExtension",
    "typeHandlerVersion": "1.0",
    "autoUpgradeMinorVersion": true,
    "settings": { }
      }
    }

> This extensions supports docker-compose... we'll check that out later.

## Deploy a VM Running Docker
**Create a resource group from the Azure-CLI:**

    az group create --name {RESOURCE GROUP NAME} -l eastus

> Replace {RESOURCE GROUP NAME} with whatever you like. The "eastus" at the end is the data center location. There something like 22+ DCs now...


## Create VM with docker using cli

```
az vm create -n MyVm -g {resourcegroupname} --image UbuntuLTS --admin-username adminuser --generate-ssh-keys --verbose
az vm extension set -n DockerExtension --publisher Microsoft.Azure.Extensions --version 1.2.2 --vm-name {vm name} --resource-group {resource group name} 
az vm list-ip-addresses -g {resourcegroupname}
```

**Alternate: Deploy an ARM Template using the Azure Portal:**


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-simple-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-simple-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


## SSH to your new Linux Box ##
From the command line we'll ssh to the server, feel free to poke around once connected.

    ssh username@{ipaddress}

> On Windows and need SSH? [Download Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).

## Docker Hello-World ##
Now that we have a docker engine to run with, let's do the defacto hello-world app...

    docker run hello-world

It's that simple... Docker went out to docker hub and downloaded the image called hello-world and ran it. You should see this output:

    Hello from Docker.
    This message shows that your installation appears to be working correctly.
    
    To generate this message, Docker took the following steps:
     1. The Docker client contacted the Docker daemon.
     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
     3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
     4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
    
    To try something more ambitious, you can run an Ubuntu container with:
     $ docker run -it ubuntu bash
    
    Share images, automate workflows, and more with a free Docker Hub account:
     https://hub.docker.com
    
    For more examples and ideas, visit:
     https://docs.docker.com/engine/userguide/

## Docker and NGINX
Next we'll run the docker image for NGINX. NGINX is an HTTP server and reverse proxy.

    docker run -d -p 80:80 nginx

This should download the image and start the container and setting up the port forwarding on port 80. To test, from your browser navigate to the url of your machine (this is the same as the SSH server).

> http://DNS-LABLE-YOU-CREATED.eastus.cloudapp.azure.com

You should see the "Welcome to NGINX" default page. Well that's it for this lab... Time to clean up.

## Create your own Docker Image ##
Use the Docker Docs and create your own image... A good place to start is:

* [Build your own images](https://docs.docker.com/engine/userguide/containers/dockerimages/)

## Delete the Resource Group ##
This command will remove everything you just created!

    az group delete --name {RESOURCE GROUP NAME} --no-wait
