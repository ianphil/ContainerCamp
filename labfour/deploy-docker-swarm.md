# How to use docker with swarm
This topic shows a very simple way to use [docker engine with in swarm mode](https://docs.docker.com/engine/swarm/) to create a swarm-managed cluster on Azure. It creates three virtual machines in Azure, one to act as the swarm manager, and two as part of the cluster of docker hosts. When you are finished, you can use swarm to see the cluster and then begin to use docker on it. 

> This topic uses docker with swarm and the Azure CLI *without* using swarm features built into **docker-machine** in order to show how the different tools work together but remain independent. **docker-machine** has **--swarm** switches that enable you to use **docker-machine** to directly add nodes to a swarm. For an example, see the [docker-machine](https://github.com/docker/machine) documentation. However, we will be using the non-swarm related **docker-machine** commands to deploy the machines to Azure and to connect to them remotely to manage the swarm.

For the differences between Docker Swarm and Docker Swarm Mode, there is a great explaination [here](http://stackoverflow.com/questions/38474424/the-relation-between-docker-swarm-and-docker-swarmkit/38483429).

## Create docker hosts with Azure Virtual Machines

This topic creates four VMs, but you can use any number you want. **docker-machine** will save the SSH keys to your local machine.

**Confirm your Azure Subscription**

    azure account set 8bae2860-70c1-4614-b55a-60e97f4248dc

**Build Swarm VMs**
Put your Subscription ID from above in the code before running these commands.  You may also want to change the azure location, resource group name and machine names to your liking. Several other switches are available with the [Azure driver](https://docs.docker.com/machine/drivers/azure/) to control the deployment. 

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-open-port 8080 --azure-ssh-user sysadmin swarm-leader

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-1

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-2

When you're done you should be able to use **azure vm list** to see your Azure VMs:

    $ azure vm list -g <RESOURCE GROUP NAME>

    data:    ResourceGroupName  Name               ProvisioningState  PowerState  Location  Size
    data:    -----------------  -----------------  -----------------  ----------  --------  -----------
    data:    swarmmodeeast      swarm-master-east  Succeeded          VM running  eastus    Standard_A1
    data:    swarmmodeeast      swarm-node1-east   Succeeded          VM running  eastus    Standard_A1
    data:    swarmmodeeast      swarm-node2-east   Succeeded          VM running  eastus    Standard_A1

Docker-Machine can also return a list of your deployed machines. Take note that you won't see any notation under the SWARM column, as we won't be using the swarm feature of docker-machine:

    $ docker-machine ls 

    NAME                ACTIVE   DRIVER   STATE     URL                          SWARM   DOCKER    ERRORS
    swarm-master-east   -        azure    Running   tcp://137.135.113.221:2376           v1.12.3
    swarm-node1-east    -        azure    Running   tcp://137.135.119.172:2376           v1.12.3
    swarm-node2-east    -        azure    Running   tcp://137.135.116.111:2376           v1.12.3

## Installing swarm on the swarm master VM

For this step, you will be using **docker-machine** to use SSH to send commands to the **swarm-master** from your Laptop using Docker. Unlike the standalone version of Docker Swarm, we do not need a respostitory/discovery service or a cluster ID to support the formation of the cluster.

    $ docker-machine ssh <MASTER VM NAME> sudo docker swarm init --advertise-addr <PRIVATE IP>

    Swarm initialized: current node (1i8hnn4v7msygj2z7nrk2p7zu) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-20sy0fq77wiu8pqx5dosb8xb2o6pf1o4j97bxmp5w6d0e9mn73-0hxovzt3xf7p0yu6n7bs9f61n \
    192.168.0.5:2377

Copy this command for use in the next step.

## Join the node VMs to your docker cluster

For each node you need to add to the swarm, run the command provided from the manager. 

    $ docker-machine ssh <NODE VM NAME> sudo docker swarm join --token SWMTKN-1-20sy0fq77wiu8pqx5dosb8xb2o6pf1o4j97bxmp5w6d0e9mn73-0hxovzt3xf7p0yu6n7bs9f61n <MASTER PRIVATE IP>:2377

To check your work, run:

    $ docker-machine ssh <MASTER VM NAME> sudo docker info

Look for the following information within the resulting output:

    Swarm: active
     NodeID: 1i8hnn4v7msygj2z7nrk2p7zu
     Is Manager: true
     ClusterID: 78f3x9oea40piz6rai37srgdv
     Managers: 1
     Nodes: 3

Repeat for all the other nodes in the cluster. In our case, we do that for **swarm-node-2** and **swarm-node-3**.

## Begin managing the swarm cluster

To list out your nodes in your cluster:

    $ docker-machine ssh <MASTER VM NAME> sudo docker node ls

    ID                           HOSTNAME           STATUS  AVAILABILITY  MANAGER STATUS
    11x87f4nbee5h7ydd6gy14avp    swarm-node2-east   Ready   Active
    1i8hnn4v7msygj2z7nrk2p7zu *  swarm-master-east  Ready   Active        Leader
    7rd1gncuhpqrzduwni28khro0    swarm-node1-east   Ready   Active

## Deploy Nginx ##
To deploy a Nginx containers run the following command:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service create --replicas 1 --name my_web --publish 8080:80 nginx

Check the service is running:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service ls

    ID            NAME           REPLICAS  IMAGE   COMMAND
    atz0nm4nx9rg  my_web         1/1       nginx

See what node the container is running on:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service ps my_web

Scale the service up to three nodes:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service scale my_web =3

Inspect the details of the service. If you leave off the "pretty" switch, you'll get a response in JSON:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service inspect --pretty my_web

Check that your website is accessible via the external IP address of one of the deployed nodes. Then delete the service:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service rm my_web

## Optional steps

1. Deploy Redis and apply rolling updates - https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/
2. Learn how to drain nodes - https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/
3. Go run other things on your swarm. To look for inspiration, see [https://github.com/docker/swarm/](https://github.com/docker/swarm/), or perhaps a [video](https://www.youtube.com/watch?v=EC25ARhZ5bI).

## Notes

In order to save credits in your Azure subscription or reduce costs, it's recommended that you STOP or DELETE the VMs after the completion of the lab.  If you stop the VMs and turn them back on at a future time, the external IP addresses will likely change.  You will need to use docker-machine regenerate-certs to update you SSH access.

