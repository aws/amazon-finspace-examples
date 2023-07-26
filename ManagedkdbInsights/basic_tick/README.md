# Setup of Basic Tick on Managed kdb Insights
This project demonstrates an implementation of a basic market data tick architecture using FinSpace Managed kdb Insights. 

# Architecture 
[Architecture of kdb+ systems](https://code.kx.com/q/architecture/)

## Managed kdb Insights Architecture 
<img src="Managed kdb Insights-BasicTick Architecture.png"  width="50%">

# Implementation Outline
## On an EC2
1. Start Ticker Plant (TP) 
2. Start Feed Handler (FH) 

## In Managed kdb Insights
1. Create and Populate a Database
2. Create Historical Database (HDB) Cluster
3. Create Real-Time Database (RDB) Cluster
4. Create Gateway (GW) Cluster
5. Query Data
6. End of Day (EOD) Processing

## 0. Setup
There are two py files that contain environment information, basictick_setup.py contains the names of the clusters and database, and another file for a specific Managed kdb environment env.py which should be renamed and filled out with the environment information of a FinSpace with Managed kdb Insights environment (items include the AWS account, environment ID, and VPC Id). That renamed file will then be imported by each of the notebooks of this project.

## On an EC2
First, install q on an EC2 instance, then using q start a Ticker Plant (TP) and a Feed Handler (FH).

### 1. Start Ticker Plant (TP) 
Start a ticker plant on an EC2 instance. 

**From Terminal**
```
cd basictick
q tp.q -p 5000
```
tp.q script found in basictick folder   

**Example Output**
```
(base) [ec2-user@ip-172-31-88-230 apricot-basic-tick]$ q tp.q -p 5000
KDB+ 4.0 2023.01.20 Copyright (C) 1993-2023 Kx Systems
l64/ 2(24)core 3907MB ec2-user ip-172-31-88-230.ec2.internal 172.31.88.230 EXPIRE 2024.01.13 johndoe@amazon.com KOD #5012053

q)tables[]
,`example
q)select[-5] from example
sym time number
---------------
```

### 2. Start Feed Handler
Start a feed handler on an EC2 and pass the host:port of the running TP when starting the feedhandler.

**From Terminal**
```
cd basictick
TP=:172.31.22.143:5000
q feedmkdb.q -p 5030 -tp $TP
q)/ Q: list connections
q).conn.procs

```
feedmkdb.q script found in basictick folder   

**Example Output**
```
(base) [ec2-user@ip-172-31-88-230 apricot-basic-tick]$ q feedmkdb.q -p 5030 -tp $TP
KDB+ 4.0 2023.01.20 Copyright (C) 1993-2023 Kx Systems
l64/ 2(24)core 3907MB ec2-user ip-172-31-88-230.ec2.internal 172.31.88.230 EXPIRE 2024.01.13 johndoe@amazon.com KOD #5012053

"connected to tp"
q).conn.procs
process address             handle connected
--------------------------------------------
tp      :172.31.88.230:5000 5      1        
q)
```

## In Managed kdb Insights

### 1. Create and Populate a Database
Create and populate a database containing one table 'example'.

**Notebook:** [create_basictickdb.ipynb](create_basictickdb.ipynb)   
**Database:** basictickdb (defined in [basictick_setup.py](basictick_setup.py))   


### 2. Create Historical Database (HDB) Cluster
Create an HDB to service queries of the hdb database (basictickdb). Deployed to the HDB is a bundle of q code in a file basictick.zip. The zip also contains an init script for the HDB (hdbmkdb.q)

**Notebook:** [create_HDB.ipynb](create_HDB.ipynb)    

- Code in zip deployed on cluster (part of creation)
- Database found in /opt/kx/app/db/basictickdb
- Cluster started with hdbmkdb.q script

### 3. Create Real-Time Database (RDB) Cluster 
Create an RDB on the same database (basictickdb) as the HDB, the database does not require any cache but having the database ensures the database and its sym file will be in the /opt/kx/app/db/basictickdb directory of the cluster.

**Notebook:** [create_RDB.ipynb](create_RDB.ipynb)    

- Code in zip deployed on cluster (part of creation)
- Database found in /opt/kx/app/db/basictickdb
- Cluster started with rdbmkdb.q script
- Cluster knows which tp to connect to from the rdbmkdb.q script's tphostfile argument
  - Be sure the file is part of the zipfile deployed with the code
  - The filename *cannot* have -._ in the name (e.g. GOOD: tickerplant, BAD: tickerplant.ini)

### 4. Create Gateways (GW) Cluster
Creaßte a Gateway cluster with create_GW notebook that will connect to and query across the named RDB and HDB clusters.

**Notebook:** [create_GW.ipynb](create_GW.ipynb)    

- Give the Gateway the names of the RDB and HDB clusters when creating

### 5. Query Data
Query the Gateway for data. Can also show the contents of example table at the RDB and HDB.

**Notebook:** [pykx_query_all.ipynb](pykx_query_all.ipynb)   
- PyKX Notebook that queries all clusters (RDB, HDB, and Gateway)

### 6. End of Day (EOD) Processing
EOD processing is triggered at end of day, the purpose is to update the new (today's) data into the historical database and then inform the HDB to 'pick up' the latest version of its data to service queries.

- RDB Executes EOD Update
  - Save in memory table to scratch space on disk
  - Add changeset to database
- Update the HDB database
  - Database version moved to just added changeset

**Notebook:** [process_EOD.ipynb](process_EOD.ipynb)
- Using Python and PyKX performs all EOD processing   
- Saves down RDB data, creates changeset, adds to database, updates HDB, re-connects GW to HDB   

# Other Notebooks

[pykx_clear_RDB.ipynb](pykx_clear_RDB.ipynb)    
Clears the RDB's example table.


[get_connectionstrings.ipynb](get_connectionstrings.ipynb)     
Given a dictionary of cluster names, generates connection stirngs the clusters.


## Notes
- If you update multiple times in the same day, you will replace the data for the day.    
