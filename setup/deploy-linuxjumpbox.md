# A Very Simple Deployment of a Linux VM through the Portal #
We're going to use the Azure portal to deploy a jumpbox for the later exercises. 

## Create the Jumpbox
1. Log into the Azure Portal at http://portal.azure.com
2. Click on the "+" in the upper right, then click on 'Compute', then select Ubuntu 16.04, and on the next page, click 'Create'.
3. On the basics page, fill in the following:
    1. **Name:**    jumpbox      *(your choice)* 
    1. **Username:**    adminuser
    1. **Authentication Type:** choose 'Password'
    2. **Password:**    *enter a password*
    3. **Resource Group:**  jumpboxrg

    Then click 'OK'

4. On the next page, choose your machine size.  Since we're not doing anything fancy on this jumpbox, a DS1_V2 is fine.
3. On the 'Settings' page, just click 'OK'
4. Finally, on the 'Summary' page, review the settings, then click 'OK'

At this point, your linux VM will begin to deploy.   This may take a minute or two.

Once your VM has deployed, take a look at the Overview page.  Click on the 'Connect' button at the top to get the ssh command to remotely log into your jumpbox.

> On Windows and need SSH? Try either [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) or  [Bitvise SSH](https://www.bitvise.com/ssh-client-download)

## Connect to the Jumpbox
From your laptop, ssh into the jumpbox.

## Install the Azure cli
1. First, you need to install some prereqs.
```
sudo apt-get update && sudo apt-get install -y libssl-dev libffi-dev python-dev build-essential
```
2. Next, install the cli
```
curl -L https://aka.ms/InstallAzureCli | bash
exec -l $SHELL
```

The cli is now installed!

Finally, configure the output to default to table format.  Run:
```
az configure
```
and follow the prompts to select 'table' as the default output.

