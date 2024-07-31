## Create Regional Metastore

There can be only one metastore per region. So if you have already a metastore created for the region, that you installed your resource groups in, you only have to make sure, that the accounts and groups in the metastore are in place. <br/>
Otherwise, if you have to install everything from scratch concerning the regional metastore, please follow this walkthrough.

1. create a Resource group. Create a resource group rg-*locationshortname*-adbuc in Azure

![create resourcegroup](/imagery/metastore-create-resourcegroup.png)

2. Create a ADLS gen 2 storage account in this resource group

make sure, that when creating the storage account, that in the advanced tab, you select *Enable hierarchical namespace*

![Hierarchical Namespace](/imagery/metastore-adlg2.png)


3. Create an Azure Databricks Access Connector

![Access Connector](/imagery/metastore-accessconnector.png)


make sure, that *System Assigned Managed Identity is On

![Managed Identity AC](/imagery/metastore-accessconector-mi.png)

4. After Access Connector is created, add a role assigment to the storage account, created earlier, in which you assign *Storage Blob Data Contributor* to the Managed Identity of the Access Connector. (the managed identity of the Access Connector has the same name as the Access Connector). Also create a container (filesystem) on storage account named *metwus3*

![Access Connector RA](/imagery/metastore-dlg2-accessconnector-ra.png)

![AC Storage Blob Contributor](/imagery/metastore-dlg2-storageblobcontributor.png)

![AC assign](/imagery/metastore-dlg2-storageblobcontributor-toac.png)

5. Create three groups: uc-metastore-admins, devcat-admins and prdcat-admnins


6. Add the service principal adb360-sp

![Add Service Principal](/imagery/metastore-spadd.png)

7. make service principal account admin

![Make Service Principal Account Admin](/imagery/metastore-sp-acctadmin.png)

8. Add Service Principal and Logged on user to uc-metastore-admins Group

![Add members to Metastore Admnins](/imagery/metastore-ucadmins-addmember.png)

9. Create a metastore *metawus3* and assign uc-metastore-admnins admins
(you find the resource id of the Access Connector in the properties of the Access Connector in the Resource Group for the metastore)

![Create metastore](/imagery/metastore-addcatalog.png)

Skip the assign metawus3 to workspaces by clicking on *Skip*

On the next screen *Edit* the metastore admins to be the uc-metastore-admins group

![Make uc-metastore-admins Metastore Admnins](/imagery/metastore-adminsasuc-metastoreadmins.png)
