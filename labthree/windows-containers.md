# Windows Containers on Windows Server
In this lab, we're going to deploy a Windows 2016 server VM running docker into Azure.  To save some time, this server will already have Docker pre-installed, and it will also have docker images for Windows Server core pre-cached.

1. To start, in your browser, go to the Azure Portal, Click on the "+" in the upper right, then in the search box type 'Windows Server 2016', then press enter to search.
2. Select the image for 'Windows Server 2016 Datacenter - with Containers', and on the right, click the 'Create' button.
3. On the basics page, fill in the following:
    1. **Name:**    winjumpbox      *(your choice)* 
    1. **Username:**    adminuser
    2. **Password:**    *enter a password*
    3. **Resource Group:**  Use existing -> jumpboxrg

    Then click the 'OK' button

4. On the next page, choose your machine size.  Since our images are somewhat larger, choose a DS2_V2.
3. On the 'Settings' page, just click 'OK'
4. Finally, on the 'Summary' page, review the settings, then click 'OK'

At this point, your Windows VM will begin to deploy.   This may take a minute or two.

Once your VM has deployed, take a look at the Overview page.  Click on the 'Connect' button at the top to launch an RDP session into your new server.

## On the Windows Server

Docker Engine should be installed and running as service. To verify Docker is running, launch Powershell and type:
```none
docker version

docker info
```

## 3. Install & Use Base Container Images

Windows containers are deployed from templates or images. Before a container can be deployed, a base OS image needs to be downloaded. To search Docker Hub for Windows container images, run `docker search Microsoft`.  

```none
docker search microsoft

NAME                                         DESCRIPTION
microsoft/aspnet                             ASP.NET is an open source server-side Web ...
microsoft/dotnet                             Official images for working with .NET Core...
mono                                         Mono is an open source implementation of M...
microsoft/azure-cli                          Docker image for Microsoft Azure Command L...
microsoft/iis                                Internet Information Services (IIS) instal...
microsoft/mssql-server-2014-express-windows  Microsoft SQL Server 2014 Express installe...
microsoft/nanoserver                         Nano Server base OS image for Windows cont...
microsoft/windowsservercore                  Windows Server Core base OS image for Wind...
microsoft/oms                                Monitor your containers using the Operatio...
microsoft/dotnet-preview                     Preview bits for microsoft/dotnet image
microsoft/dotnet35
microsoft/applicationinsights                Application Insights for Docker helps you ...
microsoft/sample-redis                       Redis installed in Windows Server Core and...
microsoft/sample-node                        Node installed in a Nano Server based cont...
microsoft/sample-nginx                       Nginx installed in Windows Server Core and...
microsoft/sample-httpd                       Apache httpd installed in Windows Server C...
microsoft/sample-dotnet                      .NET Core running in a Nano Server container
microsoft/sqlite                             SQLite installed in a Windows Server Core ...
...
```

The following command will download the Windows Server Core base image.

```none
docker pull microsoft/windowsservercore
```

Normally, this process would take some time, but this VM already has the windowservercore image precached! :)


Once the image is pulled, running `docker images` will return a list of installed images, in this case the Windows Server Core image.

```none
docker images

REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
microsoft/windowsservercore   latest              02cb7f65d61b        8 weeks ago         7.764 GB
```

## 4. Deploy Your First Container

For this exercise, you will download a pre-created IIS image from the Docker Hub registry and deploy a simple container running IIS.  
Download the IIS image using `docker pull`.  

```none
docker pull microsoft/iis
```

The image download can be verified with the `docker images` command. Notice here that you will see both the base image (windowsservercore) and the IIS image.

```none
docker images

REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
microsoft/iis                 latest              accd044753c1        11 days ago         7.907 GB
microsoft/windowsservercore   latest              02cb7f65d61b        8 weeks ago         7.764 GB
```

User `docker run` to deploy the IIS container.

```none
docker run -d -p 80:80 microsoft/iis 
```

This command runs the IIS image as a background service (-d) and configures networking such that port 80 of the container host is mapped to port 80 of the container.
For in depth information on the Docker Run command, see [Docker Run Reference on Docker.com]( https://docs.docker.com/engine/reference/run/).

Running containers can be seen with the `docker ps` command. Take note of the container name, this will be used in a later step.

```none
docker ps

CONTAINER ID  IMAGE          COMMAND              CREATED             STATUS             PORTS               NAME
09c9cc6e4f83  microsoft/iis  "C:\\ServiceMonitor..."  About a minute ago  Up About a minute  0.0.0.0:80->80/tcp  big_jang
```

Next, we want to browse to our fancy IIS website.  But first, we need to open up port 80 on the Azure network security group firewall.  Back on your linux jumpbox, run the command:
```
 az vm open-port --name winjumpbox -g jumpboxrg --port 80
```

From your laptop, open up a web browser and enter the IP address of the Windows Server host. If everything has been configured correctly, you should see the IIS splash screen. This is being served from the IIS instance hosted in the Windows container.

Back on the container host, use the `docker rm` command to remove the container. Note – replace the name of the container in this example with the actual container name.

```none
docker rm -f big_jang
```

## Next Steps

[Container Images on Windows Server](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_images)

[Windows Containers on Windows 10](https://msdn.microsoft.com/en-us/virtualization/windowscontainers/quick_start/quick_start_windows_10)
