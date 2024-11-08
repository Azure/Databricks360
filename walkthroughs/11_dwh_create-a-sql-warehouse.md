
![Create New Warehouse](/imagery/Azure_Databricks.jpg)


Workspace admins and sufficiently privileged users can configure and manage SQL warehouses. This lab outlines how to create, edit, and monitor existing SQL warehouses.
You can also create SQL warehouses using the SQL warehouse **API**, or **Terraform**.
Databricks recommends using serverless SQL warehouses when available.


---
### Requirements
* You must be a workspace admin or a user with unrestricted cluster creation permission.
* [Enable Serverless SQL Warehouses](https://learn.microsoft.com/en-us/azure/databricks/admin/sql/serverless) 
  
<br>

## Create a SQL Warehouse
---

1. Go to "SQL Warehouses" in your Databricks account and Click on "Create SQL Warehouse" button
<img src="/imagery/dwh_01_create_warehouse.jpg" alt="Create New Warehouse" width="1000" height="auto">
<br>
2. Configure SQL warehouse settings and select **Create**
<img src="/imagery/dwh_02_create_warehouse.jpeg" alt="Modify properties" width="1000" height="auto">

You can modify the following settings while creating or editing a SQL warehouse:
* **Cluster Size** represents the size of the driver node and number of worker nodes associated with the cluster. The default is X-Large. To reduce query latency, increase the size.
* **Auto Stop** determines whether the warehouse stops if it’s idle for the specified number of minutes. Idle SQL warehouses continue to accumulate DBU and cloud instance charges until they are stopped.
  * **Pro and classic SQL warehouses**: The default is 45 minutes, which is recommended for typical use. The minimum is 10 minutes.
  * **Serverless SQL warehouses**: The default is 10 minutes, which is recommended for typical use. The minimum is 5 minutes when you use the UI. Note that you can create a serverless SQL warehouse using the SQL warehouses API, in which case you can set the Auto Stop value as low as 1 minute.
* **Scaling sets** the minimum and maximum number of clusters that will be used for a query. The default is a minimum and a maximum of one cluster. You can increase the maximum clusters if you want to handle more concurrent users for a given query. Azure Databricks recommends a cluster for every 10 concurrent queries.
To maintain optimal performance, Databricks periodically recycles clusters. During a recycle period, you may temporarily see a cluster count that exceeds the maximum as Databricks transitions new workloads to the new cluster and waits to recycle the old cluster until all open workloads have completed.
* **Type** determines the type of warehouse. If serverless is enabled in your account, serverless is the default. See SQL warehouse types for the list.

**Advanced options**
Configure the following advanced options by expanding the Advanced options area when you create a new SQL warehouse or edit an existing SQL warehouse. You can also configure these options using the SQL Warehouse API.
* **Tags**: Tags allow you to monitor the cost of cloud resources used by users and groups in your organization. You specify tags as key-value pairs.
* **Unity Catalog**: If Unity Catalog is enabled for the workspace, it is the default for all new warehouses in the workspace. If Unity Catalog is not enabled for your workspace, you do not see this option. See What is Unity Catalog?.
* **Channel**: Use the Preview channel to test new functionality, including your queries and dashboards, before it becomes the Databricks SQL standard.

Your brand new SQL Warehouse is created and is by default in Running state.
<img src="/imagery/dwh_03_running_sql_warehouse.jpeg" alt="Running Warehouse" width="1000" height="auto">
<br>
3. Go to "SQL Warehouses" to view the list All SQL Warehouses that exist in your Databricks acocunt. 
<img src="/imagery/dwh_04_all_sql_warehouse.jpeg" alt="List all Warehouse" width="1000" height="auto">


