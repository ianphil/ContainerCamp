# A Very Simple Deployment of a Linux VM Running Docker #
Now it's time to run some containers!


## Docker Hello-World ##
Now that we have a docker engine to run with, let's do the defacto hello-world app...

    docker run hello-world

It's that simple... Docker went out to docker hub and downloaded the image called **hello-world** and ran it. You should see this output:

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

    docker run -d -p 80:80 --name nginx nginx
This should download the image and start the container and setting up the port forwarding on port 80. 

Now, the natural step would be to try to use our browser to navigate to our machine, right?  I'll save you some time.... this won't work.  The reason is, when we created our VM, Azure's default firewall did not allow for inbound traffic to our VM on port 80.  So to be able to hit this vm, we need to open up the firewall.  We could use the Azure portal to do this, or, as seen below, you can use the azure cli to open the port:

```bash
az vm open-port --name jumpbox -g jumpboxrg --port 80
```
**note:  this command may return an error but it actually is executing sucessfully.  This is a bug in the cli that will be fixed soon**

Now we can try hitting the web server!

To test, from your browser navigate to the url of your machine (this is the same as the SSH server).  If you don't have it handy run `az vm list-ip-addresses` to find the public ip address.

> http://[ip address of your jumpbox]

You should see the "Welcome to NGINX" default page. Well that's it for this lab.  Let's stop the current nginx container:

    docker stop nginx


## Next step:  Build your own image
Now on to the second part:  [Build your own image](buildimage.md)


## Optional, but interesting: Docker Documention ##
See the Docker Docs for more info on how to create your own images:

* [Build your own images](https://docs.docker.com/engine/userguide/containers/dockerimages/)
