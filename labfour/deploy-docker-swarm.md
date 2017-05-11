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
3. From your laptop, ssh into this server, e.g, `ssh -i ~/.ssh/acs_rsa adminuser@[ip address]` to connect to the swarm master.

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

