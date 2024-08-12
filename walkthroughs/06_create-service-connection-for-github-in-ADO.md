## Create a Service Connection for Github in ADO

In order to be able to create the Github service connection in ADO, you need a Github Personal Access Token (PAT), which you can create described [here.](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization)

* Then, if not already done so, connect and login to your ADO project from before
* open the project settings

![ADO Project Settings](/imagery/ado-project-project-settings.png)

* and in project settings -> service connections

![Service Connection](/imagery/ado-projectsettings-serviceconnections.png)

* click *Next*
* choose *Personal Access Token* and enter the access token, that you created earlier and as the name *gh-sc* and check *Grant Access permissions to all pipelines*

![Github Service Connection](/imagery/ado-gh-serviceconnection-create.png)

* Click *Verify and Save*