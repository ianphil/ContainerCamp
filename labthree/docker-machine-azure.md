# How to use docker-machine with Azure

This topic describes how to use [Docker](https://www.docker.com/) with [machine](https://github.com/docker/machine) and the [Azure CLI](https://github.com/Azure/azure-xplat-cli) to create an Azure Virtual Machine to quickly and easily manage Linux containers from a computer running Ubuntu. To demonstrate, the tutorial shows how to deploy both the [busybox Docker Hub image](https://registry.hub.docker.com/_/busybox/) image and also the [nginx Docker Hub image](https://registry.hub.docker.com/_/nginx/) and configures the container to route web requests to the nginx container. (The Docker **machine** documentation describes how to modify these instructions for other platforms.)

## Get docker-machine

If you've not already installed the docker toolbox...The quickest way to get going with **docker-machine** is to download the appropriate release directly from the [release share](https://github.com/docker/machine/releases). The client computer in this tutorial was running Ubuntu on an x64 computer, so the **docker-machine_linux-amd64** image is the one used.

## Create the certificate and key files for docker, machine, and Azure

Now you must create the certificate and key files that Azure needs to confirm your identity and permissions as well as those **docker-machine** needs to communicate with your Azure Virtual Machine to create and manage containers remotely. If you already have these files in a directory -- perhaps for use with docker -- you can reuse them. However, the best practice for testing **docker-machine** would be to create them in a separate directory and point docker-machine at them.

## Create the certificate and key files for docker, machine, and Azure

Now you must create the certificate and key files that Azure needs to confirm your identity and permissions as well as those **docker-machine** needs to communicate with your Azure Virtual Machine to create and manage containers remotely. If you already have these files in a directory -- perhaps for use with docker -- you can reuse them. However, the best practice for testing **docker-machine** would be to create them in a separate directory and point docker-machine at them.

If you have experience with Linux distributions, you may already have these files available to use on your computer in a specific place, and the [Docker HTTPS documentation explains these steps well](https://docs.docker.com/articles/https/). However, the following is the simplest form of this step.

1. Create a local folder and on the command-line, navigate to that folder and type:

		openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem
		openssl pkcs12 -export -out mycert.pfx -in mycert.pem -name "My Certificate"

	Be ready here to enter the export password for your certificate and capture it for future usage. Then type:

		openssl x509 -inform pem -in mycert.pem -outform der -out mycert.cer

2. Upload your certificate's .cer file to Azure. In the [Azure classic portal](https://manage.windowsazure.com), click **Settings** in the bottom left of the service area > and then click **Management Certificates** > and then **Upload** (at the bottom of the page) to upload the **mycert.cer** file you created in the previous step.

3. In the same **Settings** pane in the portal, click **Subscriptions** and capture the subscription ID to use when creating your VM, because you'll use it in the next step. (You can also locate the subscription id on the command line using the Azure CLI command `azure account list`, which displays the subscription id for each subscription you have in the account.)

4. Create a docker host VM on Azure using the **docker-machine create** command. The command requires the subscription ID you just captured in the previous step and the path to the **.pem** file you created in step 1. This topic uses "machine-name" as the Azure Cloud Service (and your VM) name, but you should replace that with your own choice and remember to use your cloud service name in any other step that requires the vm name. (Remember that in this example, we are using the full binary name and not a **docker-machine** symlink.)

		docker-machine create \
	    -d azure \
	    --azure-subscription-id="<subscription ID acquired above>" \
	    --azure-subscription-cert="mycert.pem" \
	    machine-name

	As the first two steps require the creation of a new VM and the loading of the Linux Azure agent as well as the updating of the new VM, you should see something like the following.

		INFO[0001] Creating Azure machine...
	    INFO[0049] Waiting for SSH...
	    modprobe: FATAL: Module aufs not found.
	    + sudo -E sh -c sleep 3; apt-get update
	    + sudo -E sh -c sleep 3; apt-get install -y -q linux-image-extra-3.13.0-36-generic
	    E: Unable to correct problems, you have held broken packages.
	    modprobe: FATAL: Module aufs not found.
	    Warning: tried to install linux-image-extra-3.13.0-36-generic (for AUFS)
	     but we still have no AUFS.  Docker may not work. Proceeding anyways!
	    + sleep 10
	    + [ https://get.docker.com/ = https://get.docker.com/ ]
	    + sudo -E sh -c apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	    gpg: requesting key A88D21E9 from hkp server keyserver.ubuntu.com
	    gpg: key A88D21E9: public key "Docker Release Tool (releasedocker) <docker@dotcloud.com>" imported
	    gpg: Total number processed: 1
	    gpg:               imported: 1  (RSA: 1)
	    + sudo -E sh -c echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list
	    + sudo -E sh -c sleep 3; apt-get update; apt-get install -y -q lxc-docker
	    + sudo -E sh -c docker version
	    INFO[0368] "machine-name" has been created and is now the active machine.
	    INFO[0368] To point your Docker client at it, run this in your shell: $(docker-machine_linux-amd64 env machine-name)

5. Set the docker and machine environment variables for the terminal session. The last line of feedback suggest that you immediately run the **env** command to export the environment variables necessary to use your docker client directly with a specific machine.

		$(docker-machine_linux-amd64 env machine-name)

	Once you do so, you do not need any special commands to use your local docker client to connect to the VM that Docker **machine** created.

	    $ docker info
	    Containers: 0
	    Images: 0
	    Storage Driver: devicemapper
	     Pool Name: docker-8:1-131736-pool
	     Pool Blocksize: 65.54 kB
	     Backing Filesystem: extfs
	     Data file: /dev/loop0
	     Metadata file: /dev/loop1
	     Data Space Used: 305.7 MB
	     Data Space Total: 107.4 GB
	     Metadata Space Used: 729.1 kB
	     Metadata Space Total: 2.147 GB
	     Udev Sync Supported: false
	     Data loop file: /var/lib/docker/devicemapper/devicemapper/data
	     Metadata loop file: /var/lib/docker/devicemapper/devicemapper/metadata
	     Library Version: 1.02.82-git (2013-10-04)
	    Execution Driver: native-0.2
	    Kernel Version: 3.13.0-36-generic
	    Operating System: Ubuntu 14.04.1 LTS
	    CPUs: 1
	    Total Memory: 1.639 GiB
	    Name: machine-name
	    ID: W3FZ:BCZW:UX24:GDSV:FR4N:N3JW:XOC2:RI56:IWQX:LRTZ:3G4P:6KJK
	    WARNING: No swap limit support

## We're done. Let's run some applications remotely using docker and images from the Docker Hub.

You can now use docker in the normal way to create an application in the container. The easiest to demonstrate is [busybox](https://registry.hub.docker.com/_/busybox/):

	    $  docker run busybox echo hello world
	    Unable to find image 'busybox:latest' locally
	    511136ea3c5a: Pull complete
	    df7546f9f060: Pull complete
	    ea13149945cb: Pull complete
	    4986bf8c1536: Pull complete
	    busybox:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
	    Status: Downloaded newer image for busybox:latest
	    hello world

However, you may want to create an application that you can see immediately on the internet, such as the [nginx](https://registry.hub.docker.com/_/nginx/) from the [Docker Hub](https://registry.hub.docker.com/).

	$ docker run --name machinenginx -P -d nginx
    Unable to find image 'nginx:latest' locally
    30d39e59ffe2: Pull complete
    c90d655b99b2: Pull complete
    d9ee0b8eeda7: Pull complete
    3225d58a895a: Pull complete
    224fea58b6cc: Pull complete
    ef9d79968cc6: Pull complete
    f22d05624ebc: Pull complete
    117696d1464e: Pull complete
    2ebe3e67fb76: Pull complete
    ad82b43d6595: Pull complete
    e90c322c3a1c: Pull complete
    4b5657a3d162: Pull complete
    511136ea3c5a: Already exists
    nginx:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
    Status: Downloaded newer image for nginx:latest
    5883e2ff55a4ba0aa55c5c9179cebb590ad86539ea1d4d367d83dc98a4976848

To see it from the internet, create a public endpoint on port 80 for the Azure VM and map that port to the nginx container's port. First, use `docker ps -a` to locate the container and find which ports **docker** has assigned to the container's port 80. (Below the displayed information is edited to show only port information; you'll see more.)

	$ docker ps -a
    IMAGE               PORTS
    nginx:latest        0.0.0.0:49153->80/tcp, 0.0.0.0:49154->443/tcp
    busybox:latest

We can see that docker has assigned the container's port 80 to the VM's port 49153. We can now use the Azure CLI to map the external Cloud Service's public port 80 to port 49153 on the VM. Docker then ensures that inbound tcp traffic on VM port 49153 is routed to the nginx container.

	$ azure vm endpoint create machine-name 80 49153
    info:    Executing command vm endpoint create
    + Getting virtual machines
    + Reading network configuration
    + Updating network configuration
    info:    vm endpoint create command OK

Open your favorite browser and have a look.

## Optional steps
Go to the [Docker user guide](https://docs.docker.com/userguide/) and create some applications on Microsoft Azure. 
