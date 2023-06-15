# Setup of Basic Tick on Managed kdb Insights
This project demonstrates an implementation of a basic market data tick architecture using FinSpace Managed kdb Insights. 

# Architectures
## Reference Archtecture
<img src="Managed kdb Insights-KX Architecture.png"  width="50%">

## Managed kdb Insights Archecture
<img src="Managed kdb Insights-GA Architecture.png"  width="50%">

# Implementation Outline
1. Create database
2. Start Ticker Plant (TP) on EC2
3. Start Feed Handler (FH) on EC2 
4. Create Historical Database (HDB)
5. Create Real-Time Database (RDB)
6. Create Gateway (GW)
7. Query Data
8. EOD Processing


## 1. Create Database
Create and populate a database containing one table 'example'.

**Notebook:** [create_basictick.ipynb](create_basictick.ipynb)   
**Database:** basictickdb   

## 2. Start TickerPlant (TP) 
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
l64/ 2(24)core 3907MB ec2-user ip-172-31-88-230.ec2.internal 172.31.88.230 EXPIRE 2024.01.13 vssaulys@amazon.com KOD #5012053

q)tables[]
,`example
q)select[-5] from example
sym time number
---------------
```

## 3. Start Feed on EC2
Start a feed handler on an EC2 and pass the host:port of the running TP when starting the feedhandler.

**From Terminal**
```
cd basictick
TP=:172.31.32.120:5000
q feedmkdb.q -p 5030 -tp $TP
q)/ Q: list connections
q).conn.procs

```
feedmkdb.q script found in basictick folder   

**Example Output**
```
(base) [ec2-user@ip-172-31-88-230 apricot-basic-tick]$ q feedmkdb.q -p 5030 -tp $TP
KDB+ 4.0 2023.01.20 Copyright (C) 1993-2023 Kx Systems
l64/ 2(24)core 3907MB ec2-user ip-172-31-88-230.ec2.internal 172.31.88.230 EXPIRE 2024.01.13 vssaulys@amazon.com KOD #5012053

"connected to tp"
q).conn.procs
process address             handle connected
--------------------------------------------
tp      :172.31.88.230:5000 5      1        
q)
```

## 4. Create HDB
Create an HDB to service queries of the hdb database (basictickdb). Deployed to the HDB is a bundle of q code in a file basictick.zip. The zip also contains an init script for the HDB (hdbmkdb.q)

**Notebook:** [create_HDB.ipynb](create_HDB.ipynb)    

- Code in zip deployed on cluster (part of creation)
- Database found in /opt/kx/app/db/basictickdb
- Cluster started with hdbmkdb.q script

## 5. Create RDB 
Create an RDB on the same database (basictickdb) as the HDB, the database does not require any cache but having the database ensures the database and its sym file will be in the /opt/kx/app/db/basictickdb directory of the cluster.

**Notebook:** [create_RDB.ipynb](create_RDB.ipynb)    

- Code in zip deployed on cluster (part of creation)
- Database found in /opt/kx/app/db/basictickdb
- Cluster started with rdbmkdb.q script
- Cluster knows which tp to connect to from the rdbmkdb.q script's tphostfile argument
  - Be sure the file is part of the zipfile deployed with the code
  - The filename *cannot* have -._ in the name (e.g. GOOD: tickerplant, BAD: tickerplant.ini)

## 6. Create GW
Creaßte a Gateway cluster with create_GW notebook that will connect to and query across the named RDB and HDB clusters.

**Notebook:** [create_GW.ipynb](create_GW.ipynb)    

- Give the Gateway the names of the RDB and HDB clusters when creating

## 7. Query Data
Query the Gateway for data. Can also show the contents of example table at the RDB and HDB.

**Notebook:** [query_RDB.ipynb](query_RDB.ipynb)   
- RDB holds current (real-time) data

**Notebook:** [query_HDB.ipynb](query_HDB.ipynb)
- HDB holds historical data

**Notebook:** [query_GW.ipynb](query_GW.ipynb)
- Gateway queries RDB and HDB and combines results

## 8. EOD Processing
EOD processing is triggered at end of day, the purpose is to update the new (today's) data into the historical database and then inform the HDB to 'pick up' the latest version of its data to service queries.

- RDB Executes EOD Update
  - Save im memory table to scratch space
  - Add changeset to database
- Update the HDB database

**Notebook:** [process_EOD.ipynb](process_EOD.ipynb)
- One notebook, using Python and PyKX to do all EOD processing   
- Saves down RDB data, creates changeset, adds to database, updates HDB, re-connects GW to HDB   

### Other Notebooks
There are singluar notebooks for each step of the EOD process as well.


**Notebook:** [create_EOD_changeset.ipynb](create_EOD_changeset.ipynb)    
**Notebook:** [update_HDB.ipynb](update_HDB.ipynb)     
**Notebook:** [update_GW.ipynb](update_GW.ipynb)     

### Notes
- If you update multiple times per day, you will be replacing data for that day    
