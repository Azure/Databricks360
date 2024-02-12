# Introduction 

This repo contains the notebooks supporting the vbd Databricks 360. There's three folders:
* init: the contents of this folder is going to set up the UC Volume on the bronze exteranl location

* tools: contains the various tools and helper scripts needed 

* historical: contains the notebooks for a historical load including the synthetic generation of test data with the help of Mimesis, a Python package. The historical load entails:
    * creating test data via Mimesis on bronze as parquet files (four tables)
    * creating a silver UC database/schema with the tables to be filled from bronze Parquet as Delta
    * creating a gold UC database/schema and loading the historical data changes via delta's Change Data Feed feature from silver to gold including reformatting the tables/schemas to a Kimball star design with SCD Type 1 and 2 dimensions

* incremental: contains the notebooks for the incremental load, such as 
    * creating the incremental data sets with inserts and updates
    * applying the incremental data set to silver delta via merge commands with watermarking
    * using the Change Data Feed capabilities of Delta to incrementally load the star on gold with SCD type 1 and 2 load as well as the fact table load


## Starting out

First start the Azure Databricks web application by going to your workspace in the Azure portal and launching the web app.

The first thing is to connect your user to the github repo by: 
* going to user settings

![user-settings](/imagery/wapp-usersettings.png)

* clicking on Settings -> User -> Linked Accounts

![linked-accounts](/imagery/wapp-linkedaccounts.png)

* go to workspace -> Repos -> Add Repo 

![add-repo](/imagery/wapp-addrepoforuser.png)

* Enter the url to the git repo, which should then populate 'Git-Provider' and 'Repository Name'

* click 'Create Repo'

Now you're ready to start working !

First with the historical load, work through all of the notebooks in order.
