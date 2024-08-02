## Add the ADO pipeline to install jobs via Databricks bundle

1. Make sure, you adjusted the variable contents in databricks.yml
2. Goto your ADO project and create a new pipeline

![ADO new Pipeline](/imagery/ado-create-new-pipeline.png)

3. Choose Github

![Choose GitHub](/imagery/ado-wheres-code.png)

4. Choose All Repositories (dropdown My Repositories) and then your repo

![Choose Repo](/imagery/ado-choose-githubrepo.png)

5. Choose Existing Azure Pipelines Yaml File

![Choose Yaml file](/imagery/ado-conf-initbundlepipeline.png)

6. Click *Continue* and then *Run*