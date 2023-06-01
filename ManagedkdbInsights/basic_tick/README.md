# Setup of Basic Tick on Managed kdb Insights

# Architectures
## Reference Archtecture
## Managed kdb Insights Archtecture

# Implementation Outline
1. Create database
2. Start TP on EC2
3. Start Feed on EC2 
4. Create HDB (deploy zip) with init script
5. Create RDB (deploy zip) with init script
6. Start GW, tell where to find RDB and HDB (connection strings)
7. EOD Processing

## 1. Create Database
Creates a database using the hdb example containing one table 'example'.

**Notebook:** create_basictick.ipynb
**Database:** basictickdb

## 2. Start TP on EC2
Start a ticker plant on an EC2 instance. For the command line workaround TP host:port is already known and also exist in the cmdline.txt file found in the basictick.zip file.

**From Terminal**
```
cd basictick
q tp.q -p 5000
```
q script found in basictick   

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
Start a feed handler on an EC2. must pass the host:port of the running TP when starting the feedhandler.

**From Terminal**
```
cd basictick
TP=:172.31.32.120:5000
q feedmkdb.q -p 5030 -tp $TP
q)/ Q: list connections
q).conn.procs

```
q script found in basictick

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

**Notebook:** create_HDB.ipynb

- Code in zip deployed on cluster (part of creation)
- database found in /opt/kx/app/db/basictickdb
- Cluster started with hdbmkdb.q script

## 5. Create RDB 
Create an RDB on the same database (basictickdb) as the HDB, the database does not require any cache but having the database ensures the database and its sym file will be in the /opt/kx/app/db/basictickdb directory of the cluster.

**Notebook:** create_RDB.ipynb

- Code in zip deployed on cluster (part of creation)
- database found in /opt/kx/app/db/basictickdb
- Cluster started with rdbmkdb.q script
- Cluster knows which tp to connect to friom init's tphostfile argument
  - Be sure the file is part of the zip deployed with the code
  - The filename *cannot* have -._ in the name (e.g. GOOD: tickerplant, BAD: tickerplant.txt)

## 7. Start GW on Managed kdb Insights
Creaßte a Gateway cluster with create_GW notebook that will connect to and query across the named RDB and HDB clusters.

**Notebook:** create_GW.ipynb

- Give the Gateway the names of the RDB and HDB clusters when creating

## 8. Query Data
Query the Gateway for data. Can also show the contents of example table at the RDB and HDB.

**Notebook:** query_gw.ipynb
**Notebook:** query_rdb.ipynb
**Notebook:** query_hdb.ipynb

**HDB** Note the number of rows per day

## 9. EOD Processing
EOD processing is triggered at end of day, the purpose is to update the new (today's) data into the historical database and then inform the HDB to 'pick up' the latest version of its data to service queries.

- RDB Executes EOD Update
  - Save im memory table to scratch space
  - Add changeset to database
- Update the HDB database

**Notebook:** create_EOD_changeset.ipynb
- Note the number of rows in the RDB (this is what will be in the changeset)

**Notebook:** update_HDB.ipynb
- Updates the HDB database to the added changeset

**Notebook:** update_GW.ipynb
- Updates the GW to get new connection strings for the updated HDB nodes

### Prove It
Demonstrate the HDB now cotains the updated records provided by the changeset added from the RDB.

- Query HDB, see newer data when compared to previous query
- Compare updated database to results from query before updates

**Notebook:** query_hdb_updated.ipynb
**Notebook (alt):** create_EOD_changeset.ipynb (end of notebook)

# Clean Up
To reset the data back to before the demo, add a delete changeset with the recently added date of data. Once the changeset is ready, go the the cluster and update it to the newest changeset. These can be done through the console.
