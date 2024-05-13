# Install Databricks CLI v2 and Configure Connection
(installation via curl - [Found Here](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/install))

> here we install on WSL/Linux. Find the github repo [here](https://github.com/databricks/cli/?tab=readme-ov-file).

1. Open a command prompt on Linux/WSL and enter the following command:

'curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh'

(Depending on your environment, you might have to insert a sudo in front of sh. Also when there is already an existing installation of the databricks cli, you'll have to first remove the prior installation via p.ex rm '/usr/local/bin/databricks')


2. Connecting to your workspace

2.1. Create a service principal in Microsoft Entra ID

2.2. Give this service account the necessary permissions in UC (Unity Catalog)

2.3. create a .databrickscfg in the user's home directory with the following structure:

```
; The profile defined in the DEFAULT section is to be used as a fallback > when no profile is explicitly specified.

[DEFAULT]

[<profilename>]
azure_tenant_id             = <tenantid>
azure_client_id             = <clientid>
azure_client_secret         = <clientsecret>
azure_workspace_resource_id = <resourceid of the databricks workspace>
```

Now you can use any databricks command with the --profile <profilename> parameter to use this profile. The workspace resourceid is necesssary to enable coummunication with accounts api.