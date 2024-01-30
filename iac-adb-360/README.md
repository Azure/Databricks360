# Installation with Azure Devops (ADO)

Firstly, you need to fork this repository (Databricks360) into your organization and then clone the repo locally. Change to the newly created directory, which should be something like /Databricks360, if you didn't rename it during the clone.

Secondly, you need to create a two service principals in your tenant (Microsoft Entra ID):
* service principal 'devops-sc' (App Registration) used for the service connection in Azure Devops (ADO), which serves as the security context for the devops agent, running your pipelines
* service principal 'adb360-sp' (App Registration) used for interaction with the Azure Databricks worspace and account (UC, more to this later). 

The installation happens in four steps:

1. The first step/script installs the basic infrastructure such as Resource Groups and assigns the necessary permissions for the service connection in ADO (Azure DevOps). The user, running the script needs to have either contributor/user access admin or owner permissions on the subscription.

    1.1. before actually running the script (/iac-adb-360/helpers/rg-create.sh), make sure to open the script in an editor and enter values for the following:
   
    1.1.1. **solutionname** - a name, which qualifies your solutions. let it be between 4 and 8 letters due to restrictions with Storage Account names etc. It is mainly used to uniquefy your artifacts
    
    1.1.2. **location** - the region/datacenter, where to install everything to
   
    1.1.3. **subscriptionid** - the subscription id of the subscription, you want to install into
   
    1.1.4. **serviceprincipalname** - the name of the service principal (app registration), you created in step 1.1
   
    1.1.5. **adbinteractprincipalname** - the name of the service principal, that is going to be used to interact with the Databricks workspace
   
    1.1.6. **locationshortname** - an abbreviation for your datacenter/region. p.ex. wus2 for westus3, eus for eastus etc. This is to help keep your resource names short.

    1.2. Run the script rg-create.sh from the command line p.ex 'bash ./iac-adb-360/helpers/rg-create.sh'

> What the script does: 
  The script takes the solution name (provided earlier) and adds the date in the form 'mmdd' as well as rg- as prefix and -dev and -prd as suffix. These names are used to generate the resource group names for the two resource groups dev and prd. After checking, that resource groups with the same name don't already exist, the resource groups are created as well as the two role assignments for the service connection: Contributor and User Access Administrator. The Databricks interaction service principal will have just Contributor permissions assigned to it.

  <br/>

  Result:
  ![Resource Groups](/imagery/resourcegroups.png)

<br/>
2. Configure the IaC pipeline to be run from within ADO or GitHub

2.1. **ADO**

2.1.1. configure the service connections in the ADO project via Project Settings/Service Connection to be using the app registration/service principal from 1.1 (devops-sc). Also in ADO the adb interaction sp (adb360-sp) needs to be in the project admins of the ADO project, since later in the pipeline, it's going to attach the repo to the Azure Databricks workspace.

2.1.2 add the pipeline found under /iac-adb-360/pipelines/azure/deploy-iac.yml as a pipeline in ADO

2.1.3 edit the config yaml files found in /iac-adb-360/pipelines/azure/configdev.yml and configprd.yml to reflect the correct Resource Group name, location and the group object id's for the kvadmins as well as the kvsecretreaders. This groups are added as keyvault admins and keyvault secret readers in the key vault, that is automatically deployed. So you'll have to create two groups with a fitting name, p.ex. kvadmins and kvsecretreaders in Microsoft Entra ID, retrieve the OIDs and edit them in the two files.

2.2. run the pipeline

This pipeline should have installed the basic infrastructure. Next there's a few provisions to be made concerning the Metastore:


> **Metastore**
Since there can only be one metastore per region and a user with GlobalAdmin role in the hosting tenant is needed to initialize a metastore, we assume, that a metastore has already been created. 
We also need to make sure, that preferrably, a group something like 'uc-metastore-owners' had been created, which should contain the adb interaction service principal from 1.1, that interacts with Databricks ('adb360-sp'). In order to do that, create the group, add the service principal to the 'service principals' in accounts and add the service principal to the group. Also add the metastore owner (globaladmin) to this group. Now assign this group as a metastore owner by going to the metastore and editing the ownership. In addition the Databricks interaction account needs to be account admin. (set this in accounts-service principals-service principal account admin) Like this, you have delegated management of the metastore to the group containing the globaladmin and the Databricks interaction service account (adb360-sp). Earlier the script, that created the Resource Groups, should have added the service principal for Adb interaction as Contributor to the Resource Groups.
After verification, that these permissions/role assignments are in place, you can continue with the next step, to configure and run the pipeline found in 'pipelines/azure/deploy-postmetastore.yml', which does the following:

* assign the Databricks workspace, which had been created by 2.2 to the metastore
* assign the Content Repo 'content-adb360' to the workspace. The repo is assigned under the service principal, not a normal user, for automated deployment to work
* create a shared cluster defined in the json 'sharedcluster.json'. To reflect the name of the new cluster. Before using the script, please adjust the cluster name in the json file.

After working through 3.x the IAC part is finished and work continues on the workspace level. 

3. **Configure and run the pipeline deploy-postmetastore.yml**
3.1. configure a variable group for the cluster pipeline /pipelines/azure/deploy-postmetastore.yml with the following:
3.1.1. **resourcegroupname** - name of the resource group
3.1.2. **tenantid** - id of Entra Instance
3.1.3. **clientid** - id of application id to interact with Databricks workspace (adb360-sp)
3.1.4. **secret** - secret of app id to interact with Databricks workspace (configured as secret)
3.1.5 **clusterconf** - the name of the file, without extension yml, which defines the cluster being created. this file is found under helpers. p.ex. sharedcluster. Don't forget to adjust the clustername in this file.
3.1.6 **metastorename** - the name of the metastore
3.1.7 **repourl** - the url to the content repo, which should be attached
3.1.8 **credname** - the credential name for the storage credential for bronze
3.2. create a pipeline from /pipelines/azure/deploy-postmetastore.yml 
3.3. assign the pipeline permissions to the variable group created earlier (library)
3.4. run the pipeline

In order for the next part to work, we need to create credentials using the managed identity of the Databricks Connector in the newly created Resource Group. Also this underlying managed identity of this connector needs to have contributor permission on the storage account, where bronze/silver/gold containers/file systems are set up. The last thing, which needs to be taken care of is to grant the Databricks interaction service principal (adb360-sp) on the newly created credentials.

5. **Configure and run the pipeline bootstrap UC catalog, schema, external location and Volume**
5.1. 


