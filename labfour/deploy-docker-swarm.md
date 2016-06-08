# How to use docker with swarm
This topic shows a very simple way to use [docker](https://www.docker.com/) with [swarm](https://github.com/docker/swarm) to create a swarm-managed cluster on Azure. It creates four virtual machines in Azure, one to act as the swarm manager, and three as part of the cluster of docker hosts. When you are finished, you can use swarm to see the cluster and then begin to use docker on it. In addition, the Azure CLI calls in this topic use the service management (asm) mode. 

> This topic uses docker with swarm and the Azure CLI *without* using **docker-machine** in order to show how the different tools work together but remain independent. **docker-machine** has **--swarm** switches that enable you to use **docker-machine** to directly add nodes to a swarm. For an example, see the [docker-machine](https://github.com/docker/machine) documentation.

## Create docker hosts with Azure Virtual Machines

This topic creates four VMs, but you can use any number you want. Call the following with *&lt;password&gt;* replaced by the password you have chosen.

**Switch Azure-CLI mode**

    azure config mode asm

**Build Swarm VMs**

    azure vm docker create swarm-master -l "East US" -e 22 $imagename ops <password>
    azure vm docker create swarm-node-1 -l "East US" -e 22 $imagename ops <password>
    azure vm docker create swarm-node-2 -l "East US" -e 22 $imagename ops <password>
    azure vm docker create swarm-node-3 -l "East US" -e 22 $imagename ops <password>

When you're done you should be able to use **azure vm list** to see your Azure VMs:

    $ azure vm list | grep "swarm-[mn]"
    data:    swarm-master     ReadyRole           East US       swarm-master.cloudapp.net                               100.78.186.65
    data:    swarm-node-1     ReadyRole           East US       swarm-node-1.cloudapp.net                               100.66.72.126
    data:    swarm-node-2     ReadyRole           East US       swarm-node-2.cloudapp.net                               100.72.18.47  
    data:    swarm-node-3     ReadyRole           East US       swarm-node-3.cloudapp.net                               100.78.24.68  

## Installing swarm on the swarm master VM

This topic uses the [container model of installation from the docker swarm documentation](https://github.com/docker/swarm#1---docker-image) -- but you could also SSH to the **swarm-master**. In this model, **swarm** is downloaded as a docker container running swarm. Below, we perform this step *remotely from our laptop by using docker* to connect to the **swarm-master** VM and tell it to use the cluster id creation command, **swarm create**. The cluster id is how **swarm** discovers the members of the swarm group. (You can also clone the repository and build it yourself, which will give you full control and enable debugging.)

    $ docker --tls -H tcp://swarm-master.cloudapp.net:2376 run --rm swarm create
    Unable to find image 'swarm:latest' locally
    511136ea3c5a: Pull complete
    a8bbe4db330c: Pull complete
    9dfb95669acc: Pull complete
    0b3950daf974: Pull complete
    633f3d9a9685: Pull complete
    bba5f98a0414: Pull complete
    defbc1ab4462: Pull complete
    92d78d321ff2: Pull complete
    swarm:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
    Status: Downloaded newer image for swarm:latest
    36731c17189fd8f450c395db8437befd

That last line is the cluster id; copy it somewhere because you will use it again when you join the node VMs to the swarm master to create the "swarm". In this example, the cluster id is **36731c17189fd8f450c395db8437befd**.

## Join the node VMs to our docker cluster

For each node, list the endpoint information using the Azure CLI. Below we do that for the **swarm-node-1** docker host in order to obtain the node's docker port.

    $ azure vm endpoint list swarm-node-1
    info:    Executing command vm endpoint list
    + Getting virtual machines
    data:    Name    Protocol  Public Port  Private Port  Virtual IP      EnableDirectServerReturn  Load Balanced
    data:    ------  --------  -----------  ------------  --------------  ------------------------  -------------
    data:    docker  tcp       2376         2376          138.91.112.194  false                     No
    data:    ssh     tcp       22           22            138.91.112.194  false                     No
    info:    vm endpoint list command OK


Using **docker** and the `-H` option to point the docker client at your node VM, join that node to the swarm you are creating by passing the cluster id and the node's docker port (the latter using **--addr**):

    $ docker --tls -H tcp://swarm-node-1.cloudapp.net:2376 run -d swarm join --addr=138.91.112.194:2376 token://36731c17189fd8f450c395db8437befd
    Unable to find image 'swarm:latest' locally
    511136ea3c5a: Pull complete
    a8bbe4db330c: Pull complete
    9dfb95669acc: Pull complete
    0b3950daf974: Pull complete
    633f3d9a9685: Pull complete
    bba5f98a0414: Pull complete
    defbc1ab4462: Pull complete
    92d78d321ff2: Pull complete
    swarm:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
    Status: Downloaded newer image for swarm:latest
    bbf88f61300bf876c6202d4cf886874b363cd7e2899345ac34dc8ab10c7ae924

That looks good. To confirm that **swarm** is running on **swarm-node-1** we type:

    $ docker --tls -H tcp://swarm-node-1.cloudapp.net:2376 ps -a
        CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS               NAMES
        bbf88f61300b        swarm:latest        "/swarm join --addr=   13 seconds ago      Up 12 seconds       2375/tcp            angry_mclean

Repeat for all the other nodes in the cluster. In our case, we do that for **swarm-node-2** and **swarm-node-3**.

## Begin managing the swarm cluster

    $ docker --tls -H tcp://swarm-master.cloudapp.net:2376 run -d -p 2375:2375 swarm manage token://36731c17189fd8f450c395db8437befd
    d7e87c2c147ade438cb4b663bda0ee20981d4818770958f5d317d6aebdcaedd5

and then you can list out your nodes in your cluster:

    $ docker --tls -H tcp://swarm-master.cloudapp.net:2376 run --rm swarm list token://73f8bc512e94195210fad6e9cd58986f
    54.149.104.203:2375
    54.187.164.89:2375
    92.222.76.190:2375

## Deploy Redis ##
To deploy a Redis container run the following command:

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 run --name some-redis -d redis

To see where on the cluster it was scheduled: 

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 ps

## Deploy Ubuntu Container ##

To deploy an Ubuntu container run the following command:

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 run --name some-ubuntu -d ubuntu

To see where on the cluster it was scheduled: 

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 ps

## Deploy Jenkins ##

To deploy a Jenkins container run the following command:

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 run -p 8080:8080 -p 50000:50000 jenkins

To see where on the cluster it was scheduled: 

    docker --tls -H tcp://swarm-master.cloudapp.net:2376 ps

## Optional steps

1. Try to write to your Redis container from your Ubuntu container.
2. Try to access the Jenkins Web Interface on port 8080.
3. Go run other things on your swarm. To look for inspiration, see [https://github.com/docker/swarm/](https://github.com/docker/swarm/), or perhaps a [video](https://www.youtube.com/watch?v=EC25ARhZ5bI).