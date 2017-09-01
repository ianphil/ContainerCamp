# Running the Azure cli

Many of the exercises in the lab will use the Azure Cross Platform cli. The easiest way to run the cli is through a Docker container that has the cli pre-installed! The next section has instructions for running this container, but if you wish to install the cli on your laptop and run it directly, that is also possible and instructions are below.

### Installing and running the Azure cli in a Docker container
Start docker, and then open a command shell (on Windows, either a command prompt or a Powershell command).  
```
docker run -it azuresdk/azure-cli-python
```

