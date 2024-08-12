## Create Variable Group

1. Goto ADO -> Your project -> Pipelines -> Library -> + Variable Group

![create variable group](/imagery/ado-create-var-group.png)

2. Enter *'vgdevadb360'* as the name and Click on Add to add the following variables:
    * resourcegroupname: the dev resource group name
    * tenantid: the id of the tenant (was noted down when creating the service principals)
    * clientid: appid/clientid adb interactive service principal
    * clientsecret: secret for appid (click on the Lock symbol to the right to change to a variable type secret)
    * clusterconf: the json file name, which contains the clusterconfiguration being used (usually sharedcluster)
    * meatstorename: the name of the metastore (p.ex. metawus3)
    * reporurl: the url to the github repo (p.ex. https://github.com/*yourorg*/Databricks360.git)
    * credname: the name of the credential used for the bronze external location (p.ex. devcreds)
    * env: the environment (p.ex. dev)
    * bronzestorageaccountname: the storage account name for the storage account for the bronze volume (the storage account anme in the dev resource group starting with dlg2devwestus3adb360...)
    * catalogstorageaccountname: the other storage account (starting with dlg2metastoredevwest...)
    * accessconnectorid: the resource id of the Databricks access connector created in the resource group (starting with adbac-wus3-adb...)
    * ghuser: your github user account name
    * ghpat: the github personal access token, you created earlier (make this alsoe a variable of type secret)

Click on *Save* to save the variable group and then on *pipeline permissions*  open access via the three dots, since you don't know the pipeline name yet

![Variable Group Permissions](/imagery/ado-set-variablegroup-perm.png)

3. create a new pipeline by going to Pipelines->Pipelines->New Pipeline

![Create New Pipeline](/imagery/ado-create-new-pipeline.png)

    a. choose *Github*

![Where is the code](/imagery/ado-wheres-code.png)

    b. if necessary click on *All Repositories* and then choose yours

![Select Repo](/imagery/ado-choose-githubrepo.png)

    c. on *configure your pipeline* choose *Existing Azure Pipelines YAML file*, make sure *dev* is selected and choose */iac-adb-360/pipelines/azure/deploy-postmetastore.yml*

![Select Pipeline Type](/imagery/ado-configure-your-pipeline.png)


    d. Click *Continue* at the lower right bottom and then open the dropdown of *Run* and choose *Save*

    e. Click on *Run Pipeline*, choose *dev*

![Run Pipeline](/imagery/ado-run-pipeline.png)



This is going to run the *postmetastore* pipeline. Make sure it runs successfully by verifying, that:
* the workspace is assigned to the metastore (see accounts.azuredatabricks.net)
![Workspace assigned to Metastore](/imagery/adb-assignedws-tometastore.png)

* the github repo is assigned (see Databricks Resource Group -> Workspace -> Launch Workspace -> Workspace)
![Git Repo connected to Workspace](/imagery/adbws-workspace-gitrepo.png)

* and that the cluster is created (via adb-workspace->Compute)
![Cluster Created](/imagery/adbws-cluster-created.png)