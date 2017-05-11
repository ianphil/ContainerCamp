# Connect to an Azure subscription from the Azure Command-Line Interface (Azure CLI)

The Azure CLI is a set of open-source, cross-platform commands for working with the Azure platform. This article describes how to connect to your Azure subscription from the Azure CLI to use all of the CLI commands. If you haven't already installed the CLI, see [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## Use the interactive log in method

Use the `az login` command -- without any arguments -- to authenticate interactively with either:

- a work or school account identity that requires multi-factor authentication, or
- a Microsoft account identity when you want to access Resource Manager deployment mode functionality

Interactively logging in is easy: type `az login` and follow the prompts as shown below:

az login                                                                                                                                                                                         
*To sign in, use a web browser to open the page http://aka.ms/devicelogin. Enter the code XXXXXXXXX to authenticate. If you're signing in as an Azure AD application, use the --username and --password parameters.*

Copy the code offered to you, above, and open a browser to http://aka.ms/devicelogin. Enter the code, and then you are prompted to enter the username and password for the identity you want to use. When that process completes, the command shell completes the log in process. Confirm you're logged in by running:

```
az account list
```


