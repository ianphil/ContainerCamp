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


