# How to use docker with swarm
This lab will create a docker swarm mode cluster using acs-engine.

## Deploy the cluster
1. First, go back to your linux jumpbox and run the following command to generate ssh keys that will be used later in the exercise:  (leave the pasphrase blank)
```
ssh-keygen -t rsa -b 2048 -C "acsadmin@acs" -f ~/.ssh/acs_rsa
```
then:
```
cat ~/.ssh/acs_rsa.pub
```
> Alternatively, if you are comfortable, you can use your local SSH program (such as Bitvise or Putty) to generate the SSH keys.  Just adapt the instructions as necessary.

2. Now we're going to create the swarm mode cluster by launching the following template in the Azure portal:  (I recommend you right-click on the link and say 'open in new window' so you can easily come back here):<br>
<!--
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F101-acsengine-swarmmode%2Fazuredeploy.json" target="_blank">     <img src="http://azuredeploy.net/deploybutton.png"/> </a>
-->
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Flarryms%2FContainerCamp%2Fmaster%2Flabfour%2Fswarmmode%2Fazuredeploy.json" target="_blank">     <img src="http://azuredeploy.net/deploybutton.png"/> </a>

## Install docker-machine
To run this lab, you will need to install `docker-machine` locally. Please see the [installation instructions](https://docs.docker.com/machine/install-machine/) to get started.

## Create docker hosts with Azure Virtual Machines
Fill in the following:

1. **Resource Group:**  Create new -> 'swarmmoderg'
2. **Agent Count:**   2
3. **Endpoint DNS Name Prefix:**  [yourinitials]lab
4. **Admin username:**  adminuser
4. **Location:** eastus
4. **Master Endpoint DNS Name Prefix:** [yourinitials]master
5. **Master VM Size:**  Standard_DS2_V2
6. **SSH Public Key:**  *paste in the pubic RSA key from step 1*    

Then press the 'Puchase' button and the cluster will deploy.

## Connect to the Cluster
Now that the cluster is deployed, we need to ssh to the master.  The first step is to find the IP address that was assigned to the loadbalancer in front of the master.

1. In the portal, go into the resource group for the swarm cluster you just created, scroll down to 'Deployments', then click on "Microsoft.Template".  
2. You will see a field titled **MASTERFQDN**.  Copy the value of this field as it is the DNS name of your master.  Also note the field **AGENTFQDN** which is the DNS name of the load balancer setting in front of your cluster.  (_You'll need this later_)
3. From your laptop, ssh into this server, e.g, `ssh -i ~/.ssh/acs_rsa adminuser@[MASTERFQDN]` to connect to the swarm master.

Now that you are on the swarm master, check the status of the cluster by running:

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-1

    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-2
    
    $ docker-machine create --driver azure --azure-subscription-id <SUB ID> --azure-location westus --azure-size Standard_A1 --azure-resource-group ContainersSwarmMode --azure-ssh-user sysadmin swarm-node-3

When you're done you should be able to use **azure vm list** to see your Azure VMs:

    $ azure vm list -g <RESOURCE GROUP NAME>

    data:    ResourceGroupName   Name               ProvisioningState  PowerState  Location  Size
    data:    -----------------   -----------------  -----------------  ----------  --------  -----------
    data:    ContainersSwarmMode swarm-leader       Succeeded          VM running  eastus    Standard_A1
    data:    ContainersSwarmMode swarm-node-1       Succeeded          VM running  eastus    Standard_A1
    data:    ContainersSwarmMode swarm-node-2       Succeeded          VM running  eastus    Standard_A1
    data:    ContainersSwarmMode swarm-node-3       Succeeded          VM running  eastus    Standard_A1

Docker-Machine can also return a list of your deployed machines. Take note that you won't see any notation under the SWARM column, as we won't be using the swarm feature of docker-machine:

    $ docker-machine ls 

    NAME                ACTIVE   DRIVER   STATE     URL                          SWARM   DOCKER    ERRORS
    swarm-leader        -        azure    Running   tcp://137.135.113.221:2376           v1.13.0
    swarm-node-1        -        azure    Running   tcp://137.135.119.172:2376           v1.13.0
    swarm-node-2        -        azure    Running   tcp://137.135.116.111:2376           v1.13.0
    swarm-node-3        -        azure    Running   tcp://137.135.114.123:2376           v1.13.0

## Installing swarm on the swarm master VM

For this step, you will be using **docker-machine** to use SSH to send commands to the **swarm-master** from your Laptop using Docker. Unlike the standalone version of Docker Swarm, we do not need a respostitory/discovery service or a cluster ID to support the formation of the cluster.

You will need to initialize the swarm on the master node and tell it to listen on its private address.

First, let's get the private IP of the master node.

    $ docker-machine ssh <MASTER VM NAME> sudo ifconfig | grep eth0 -A 2
    
This will return the internal IP on the network card. You should see the following:

    eth0      Link encap:Ethernet  HWaddr 00:0d:3a:17:82:b2  
              inet addr:192.168.0.4  Bcast:192.168.255.255  Mask:255.255.0.0
              inet6 addr: fe80::20d:3aff:fe17:82b2/64 Scope:Link

The `inet addr` is the internal/private IP you will use in this next step. Now, initialize the swarm that private IP.

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
    docker info

Look for the following information within the resulting output:

    Swarm: active
     NodeID: 1i8hnn4v7msygj2z7nrk2p7zu
     Is Manager: true
     ClusterID: 78f3x9oea40piz6rai37srgdv
     Managers: 1
     Nodes: 3


## Begin managing the swarm cluster

First, let's do a little work to configure our cluster for this lab:

    git clone https://github.com/larryms/ContainerCamp.git  
    sh ~/ContainerCamp/labfour/configswarm.sh


Now the cluster is ready to go!

    ID                           HOSTNAME           STATUS  AVAILABILITY  MANAGER STATUS
    11x87f4nbee5h7ydd6gy14avp    swarm-node-2       Ready   Active
    1i8hnn4v7msygj2z7nrk2p7zu *  swarm-leader       Ready   Active        Leader
    7rd1gncuhpqrzduwni28khro0    swarm-node-1       Ready   Active
    jdzwv06lzx9qzk6yyuveoy5xd    swarm-node-3       Ready   Active

To view the nodes in your cluster:

    docker node ls

    ID                            HOSTNAME                      STATUS              AVAILABILITY        MANAGER STATUS
    9kexly729ylezsqc6pow6zws7     swarmm-agent-13957614000000   Ready               Active
    kc2sht405ewdmi2qxytsf7y0w     swarmm-agent-13957614000002   Ready               Active
    nzd4h33heoyobqumqmcn8snue *   swarmm-master-13957614-0      Ready               Active               Leader
    
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

    $ docker-machine ssh <MASTER VM NAME> sudo docker service scale my_web=3

Inspect the details of the service. If you leave off the "pretty" switch, you'll get a response in JSON:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service inspect --pretty my_web

Check that your website is accessible via the external IP address of the leader/master node. (The other nodes are inaccessible via port 8080 unless the port is opened on the firewall in Azure.) 

    $ docker-machine ls | grep <MASTER VM NAME>
    
    swarm-leader   -        azure    Running   tcp://40.117.195.87:2376           v1.13.0
    
Open a web browser to the returned IP address with the web server's exposed port (e.g. `http://40.117.195.87:8080`, in this case).

Then, delete the service:

    $ docker-machine ssh <MASTER VM NAME> sudo docker service rm my_web

## Optional steps

1. Deploy Redis and apply rolling updates - https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/
2. Learn how to drain nodes - https://docs.docker.com/engine/swarm/swarm-tutorial/drain-node/
3. Go run other things on your swarm. To look for inspiration, see [https://github.com/docker/swarm/](https://github.com/docker/swarm/), or perhaps a [video](https://www.youtube.com/watch?v=EC25ARhZ5bI).

## Notes

In order to save credits in your Azure subscription or reduce costs, it's recommended that you STOP or DELETE the VMs after the completion of the lab.  If you stop the VMs and turn them back on at a future time, the external IP addresses will likely change.  You will need to use docker-machine regenerate-certs to update you SSH access.
    docker service scale my_web=3

Inspect the details of the service. If you leave off the "pretty" switch, you'll get a response in JSON:

    docker service inspect --pretty my_web

From your browser on your laptop, browse to http://[AGENTFQDN]. You should see the nginx welcome screen.

## Graphically inspect the cluster

Let's use the Docker Visualizer to visually inspect our cluster. 
Run the following command to load Docker Visualizer:
```
docker service create \
  --name=viz \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
  ```
Now in your browser, open a new tab and go to http://[AGENTFQDN]:8080
> Note the above is _**AGENTFQDN**_, not _MASTERFQDN_.  

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

## Optional steps:  Monitor your cluster
On your swarm master, run the following to set up your secrets:
```
export WSID=<your workspace id>
export KEY=<your secret key>
echo $WSID | docker secret create WSID -
echo $KEY |  docker secret create KEY -
docker secret ls
```
Then run:
```
 docker service create --name omsagent --mode global --mount type=bind, \
 source=/var/run/docker.sock,destination=/var/run/docker.sock --secret source=WSID, \
 target=WSID --secret source=KEY,target=KEY -p 25225:25225 -p 25224:25224/udp \
 --restart-condition=on-failure microsoft/oms:test1
 ```
 And in a few minutes, you should see your swarm appear in your OMS workspace.


