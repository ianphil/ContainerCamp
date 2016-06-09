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

    azure group create {RESOURCE GROUP NAME} eastus

> Replace {RESOURCE GROUP NAME} with whatever you like. The "eastus" at the end is the data center location. There something like 22+ DCs now...

**Deploy an ARM Template using the Azure-CLI:**

    azure group deployment create <my-resource-group> <my-deployment-name> --template-uri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/docker-simple-on-ubuntu/azuredeploy.json

> Replace {RESOURCE GROUP NAME} with the resource group name you just created.

> Replace {DEPLOYMENT NAME} with whatever you like.

This command creates a deployment with the resource manager and passes the URI of the Docker template. It will also prompt you for the following parameters:

1. Username (don't use "admin")
2. Password (needs to be more than 8 chars and be complex)
3. DNS Label (this will be the dns prefix used to connect to the box)
4. Storage Account Name (blob storage for VM Disks)

## SSH to your new Linux Box ##
From the command line we'll ssh to the server, feel free to poke around once connected.

    ssh username@DNS-LABLE-YOU-CREATED.eastus.cloudapp.azure.com

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

    azure group delete {RESOURCE GROUP NAME} -q