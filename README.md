# ADB - 360

> This project is supporting the VBD ADB 360, which strives to be a 360 degree end to end solution of Azure Databricks implementing a lakehouse on a medallion architecture, supported by Unity Catalog.
The end to end solution demonstrates the following concepts:
* CICD of Azure Databricks with infrastructure as Code (IAC) 
* CICD of a complete medallion architecture (Bronze/Silver/Gold) via Databricks Asset Bundles
* Unity Catalog Integration

<br/>
<br/>

![Azure Databricks](imagery/adb.jpg)

<br/>
<br/>


## Structure of Repo

The Repository is structure into two main parts:
* [IAC](/iac-adb-360/README.md) : Infrastructure as code in directory iac-adb-360
* [Content](/bundle_adb_360/README.md) : the notebooks and workflow definitions to implement the lakehouse with the medallion architecture via Databricks Asset Bundles



Here is the overall Process:

```mermaid
flowchart TD
Start --> IaC
style Start fill:red,stroke:blue,stroke-width:3px,shadow:shadow
IaC --> Content(Content in bundle_adb_360)
style IaC fill:darkgray,stroke:blue,stroke-witdth:3px,shadow:shadow,color:#0000aa
Content --> End
style Content fill:darkgray,stroke:blue,stroke-witdth:3px,shadow:shadow,color:#0000aa
style End fill:red,stroke:blue,stroke-width:3px,shadow:shadow


```
<br/>
<br/>


Next Step: [Start reading how to set up the infrastucture via IaC pipelines](/iac-adb-360/README.md)







---
* Other helpful links:
    * [Install Databricks CLI v 2.0 (> 0.205)](https://docs.databricks.com/en/dev-tools/cli/install.html)
    GA as of March 14, 2024

<br/>
<br/>

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
