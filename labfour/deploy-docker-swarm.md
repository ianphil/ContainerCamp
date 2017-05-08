# How to use docker with swarm
This lab will create a docker swarm mode cluster using acs-engine.

## Deploy the cluster
1. First, go back to your linux jumpbox and run the following command to generate ssh keys that will be used later in the exercise:  (leave the pasphrase blank)
```
ssh-keygen -t rsa -b 2048 -C "acsadmin@acs" -f ~/.ssh/acs_rsa
cat ~/.ssh/acs_rsa.pub
```
2. Now we're going to create the swarm mode cluster by launching the following templte in the Azure portal:  (I recommend you right-click on the link and say 'open in new window' so you can easily come back here):
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-acsengine-swarmmode%2Fazuredeploy.json" target="_blank">     <img src="http://azuredeploy.net/deploybutton.png"/> </a>
    
    Fill in the following:
    1. **Resource Group:**  Create new -> 'swarmmoderg'
    2. **Agent Count:**   2
    3. **Endpoint DNS Name Prefix:**  [yourinitials]lab
    4. **Admin username:**  adminuser
    4. **Location:** eastus
    4. **Master Endpoint DNS Name Prefix:** [yourinitials]master
    5. **Master VM Size:**  Standard_D2_V2
    6. **SSH Public Key:**  *paste in the pubic RSA key from step 1*    

    Then press the 'Puchase' button and the cluster will deploy.

## Connect to the Cluster
Now that the cluster is deployed, we need to ssh to the master.  The first step is to find the IP address that was assigned to the loadbalancer in front of the master.

1. Go into the resource group, find the load balancer that has a name like _swarmm-master-lb-13957614_, and click on it.
2. On the screen that is displayed, you will see the public IP address listed.  Make note of this.
3. From your ssh into this server, e.g, `ssh -i ~/.ssh/acs_rsa adminuser@[ip address]` to connect to the swarm master.

Now that you are on the swarm master, check the status of the cluster by running:

    docker info

Look for the following information within the resulting output:

    Swarm: active
     NodeID: 1i8hnn4v7msygj2z7nrk2p7zu
     Is Manager: true
     ClusterID: 78f3x9oea40piz6rai37srgdv
     Managers: 1
     Nodes: 3


## Begin managing the swarm cluster

To list out your nodes in your cluster:

    docker node ls

    ID                            HOSTNAME                      STATUS              AVAILABILITY        MANAGER STATUS
    9kexly729ylezsqc6pow6zws7     swarmm-agent-13957614000000   Ready               Active
    kc2sht405ewdmi2qxytsf7y0w     swarmm-agent-13957614000002   Ready               Active
    nzd4h33heoyobqumqmcn8snue *   swarmm-master-13957614-0      Ready               Pause               Leader
    
## Deploy Nginx ##
To deploy an Nginx container run the following command:

    docker service create --replicas 1 --name my_web --publish 80:80 nginx

Check the service is running:

    docker service ls

    ID            NAME           REPLICAS  IMAGE   COMMAND
    atz0nm4nx9rg  my_web         1/1       nginx

See what node the container is running on:

    docker service ps my_web

Scale the service up to three nodes:

    docker service scale my_web=3

Inspect the details of the service. If you leave off the "pretty" switch, you'll get a response in JSON:

    docker service inspect --pretty my_web

Check that your website is accessible via the external IP address of one of the deployed nodes.  We need to get the IP address of the load balancer deployed in front of the agent group: 
1. First, go back to the azure portal,  go back to the resource group, and find the load balancer that has a name like _swarmm-agend-lb-13957614_, and click on it.
2. On the screen that is displayed, you will see the public IP address listed.  Make note of this.

From your browser on your laptop, browse to http://[ip address of agent lb]. You should see the nginx welcome screen.

## Graphically inspect the cluster

Let's use the Docker Visualizer to visually inspect our cluster. 
1. From the ssh session connected to the master, run: `docker node ls` and make note of the node name of the master
2. Run the following:  `docker node update --availability active [node name of the master]`
3. Run the following command to load Docker Visualizer:
```
docker service create \
  --name=viz \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
  ```
4. In your browser, go to the Azure portal, go back to the resource group, find the load balancer that has a name like _swarmm-master-lb-13957614_, and click on it
5. Click on 'Inbound Nat Rules', then click "+ Add" to add a rule
6. Fill in the following:
    1. **Name** Master8080
    2. **Port** 8080
    3. **Target Virtual Machine**  Select your master
    4. **Network IP Configuration**  Select the IP of the master

    Press 'OK'

7. Now in your browser, open a new tab and go to http://[ip address of the Master LB]:8080

You should see a graphical vizualization of your cluster.  You can watch it scale your services up and down:

    docker service scale my_web=5
    [look at Docker Visualizer]
    docker service scale my_web=1
    [look at Docker Visualizer]
    docker service scale my_web=5
    [look at Docker Visualizer]

Now mark a node as unavailable, and watch Swarm re-allocate the containers:
    
    docker node ls
    [make a note of one of the agent node names]
    docker node update --availability=drain [agent node name]
    [look at docker visualizer ]
    docker node update --availability active [agent node name]

Finally, delete the service:

    docker service rm my_web

## Optional steps

1. Deploy Redis and apply rolling updates - https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/
2. Learn how to drain nodes - https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/
3. Go run other things on your swarm. To look for inspiration, see [https://github.com/docker/swarm/](https://github.com/docker/swarm/), or perhaps a [video](https://www.youtube.com/watch?v=EC25ARhZ5bI).



----------------------------
# How to use docker with swarm
This lab will create a docker swarm  cluster using Azure Container Service

1. First, go back to your linux jumpbox and run the following command to generate ssh keys that will be used later in the exercise:  (leave the pasphrase blank)
```
ssh-keygen -t rsa -b 2048 -C "acsadmin@acs" -f ~/.ssh/acs_rsa
cat ~/.ssh/acs_rsa.pub
```

2. Now go to your browser and click the "+", then select 'Containers, then select 'Azure Container Service'
3. On the 'Basics' page, choose the following:
    1. **Orchestrator** -> Swarm
    2. **Resource Group** -> Create new 'swarmrg'

        Press the 'OK' button
4. 



-------------------------------------
This topic shows a very simple way to use [docker engine with in swarm mode](https://docs.docker.com/engine/swarm/) to create a swarm-managed cluster on Azure. It creates three virtual machines in Azure, one to act as the swarm manager, and two as part of the cluster of docker hosts. When you are finished, you can use swarm to see the cluster and then begin to use docker on it. 

> This topic uses docker with swarm and the Azure CLI *without* using legacy swarm features built into **docker-machine**. **docker-machine** has **--swarm** switches that enable you to use **docker-machine** to directly add nodes to a swarm, but these implement the legacy swarm service, not the newer **swarm-mode**. For an example, see the [docker-machine](https://github.com/docker/machine) documentation. However, we will be using the non-swarm related **docker-machine** commands to deploy the machines to Azure and to connect to them remotely to manage swarm-mode.

For the differences between Docker Swarm and Docker Swarm Mode, there is a great explaination [here](http://stackoverflow.com/questions/38474424/the-relation-between-docker-swarm-and-docker-swarmkit/38483429).

## Create docker hosts with Azure Virtual Machines

This topic creates four VMs, but you can use any number you want. **docker-machine** will save the SSH keys to your local machine.

**Confirm your Azure Subscription**

    az account list

**Build Swarm VMs**
Put your Subscription ID from above in the code before running these commands.  You may also want to change the azure location, resource group name and machine names to your liking. Several other switches are available with the [Azure driver](https://docs.docker.com/machine/drivers/azure/) to control the deployment. 

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-open-port 8080 --azure-ssh-user sysadmin swarm-master-east

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-1

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-2

When you're done you should be able to use **azure vm list** to see your Azure VMs:

    $ az vm list -g <RESOURCE GROUP NAME>

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

    $ docker-machine ssh <MASTER VM NAME> sudo docker service scale my_web=3

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

