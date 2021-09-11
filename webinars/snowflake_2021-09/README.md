# Financial Services Data Summit
## Session
[Making Financial Data More Accessible in the Cloud](https://www.snowflake.com/financial-services-data-summit/americas/agenda/?agendaPath=session/615483)  
**Date:** Sept 14, 2021  

### Agenda
Join this session to learn how AWS and Snowflake are innovating to make it easier for financial customers to share, manage, and analyze financial content in the cloud. Leading Financial Markets Operator TP ICAP will showcase their use of Snowflake running on AWS within the Parameta Solutions business to share market data and analytics amongst clients who use proprietary models built to run written in Python. Then AWS will demonstrate the benefits of incorporating data from Snowflake into Amazon FinSpace, a new service to provide customers with a scalable research environment that offers integrated data management, analytics, and governance.

## FinSpace Prerequisits
- Capital Markets Sample Data bundle has been installed in the environment    
- Category 'Source' contains a sub-category named 'Snowflake' 
- Attribute set named 'Snowflake Table Attributes' exists with fields
  - Name: Catalog, Type: String
  - Name: Schema, Type: String
  - Name: Table, Type: String
  - Name: Source, Type: Category: Source

### snowflake.ini
It is assumed that there exists in this same folder with the notebooks a customer provided snowflake.ini file
that contains snowflake instance information and authentication credentials.

#### Contents of snowflake.ini
```
[snowflake]  
user: USERNAME  
password: PASSWORD  
account: ACCOUNT  
database: DATABASE  
warehouse: WAREHOUSE
```
Please provide values from your snowflake installation for: USERNAME, PASSWORD, ACCOUNT, DATABASE, and WAREHOUSE    

## Code Artifacts
Code artifacts from the demonstration given at the summit  

### Notebooks
[Delete Datasets](delete_datasets.ipynb) Deletes all datasets with a given classification (Source) and value (Snowflake)  
[Snowflake Import](snowflake_import.ipynb) Notebook that creates a FinSpace dataset for each table in the given snowflake table  
[Plot Volatility](plot-volatility-snowflake.ipynb) Notebook to plot volatility then add and plots events over the volatility plot, presented in session  

### Python
[finspace.py](finspace.py) Utility class for working with FinSpace boto3 service API  
[finspace_spark.py](finspace_spark.py) Utility class for works with Spark and FinSpace boto3 service API  

### Other
[finspace_logo.png](finspace_logo.png) FinSpace logo in notebooks  
[workflow.png](workflow.png) FinSpace time-series library workflow image     