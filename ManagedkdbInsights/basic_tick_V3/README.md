# Basic Tick V3 on Managed kdb Insights
This project  implementats a basic market data tick architecture using FinSpace Managed kdb Insights. 

## Reference Architecture 
[Architecture of kdb+ systems](https://code.kx.com/q/architecture/)

## Managed kdb Insights Architecture 
<img src="images/Deepdive Diagrams-BasicTick V3.drawio.png"  width="50%">

# Implementation
A feed handler (FH) simulates data that would be coming from a trading venue, in this case it will be publishing trade and quote data which will be distributed by the tickerplant (TP). A Complex event processor (CEP) will subscribe to the tickerplant's trade and quote events and then will calculate/maintain a set of tables that are updated as each trade or quote event is published to the CEP. The CEP will maintain three tables: trade_hlcv (trade by sym: high, low, close, volume), trade_last (last trade price and size, by sym) and 
trade_vwap (solume weighted average price and total volume by sym). The realtime database (RDB) will subscribe to the TP and collect in a table all trades and quotes from the TP for today. The historical database (HDB) has historical data, trade and quote tables from previous days. The gateway acts as an aggregator for all data in the application and when queried will query both the RDB and HDB and then combine the results into one result before responding to the query requesting client.

## End of Day Processing (EOD)
At the end of the day, the RDB will save all its collected in memory data for tades and quotes and create a new changeset that is added to the managed database and then update the dataview and HDB to use the newly updated state of the managed database.

For details see the .rdb.eod function in [rdbmkdb.q](basictick/rdbmkdb.q)

# Notebooks

**Notebook:** [create_all.ipynb](create_all.ipynb)   
This notebook performs all infrastructure setup and runs all the kdb processes (clusters) of this application. Setup also include starting a non-managed component, the Feedhandler (FH) that simulates a market data provider sending its data to kdb.

1. Create and Populate a Managed Database
2. Create a Scaling Group
3. Create a Shared Volume
4. Create a Dataview of the Database on the shared volume
5. Create Clusters  
    * Tickerplant (TP)
    * Historical Database (HDB)
    * Gateway (GW)
    * Realtime Database (RDB)
    * Calc Engine (RDB)
9. Start a Local FeedHandler (FH)

**Notebook:** [pykx_query_all.ipynb](pykx_query_all.ipynb)   

This notebook queries the managed kdb processes directly to show their contents and specifically queries the gateway process to collect and aggregate data from the RDB and HDB.

**Notebook:** [pykx_sub_calc.ipynb](pykx_sub_calc.ipynb)   

This notebook demonstrates connecting to the Calc (CEP) process and collecting latency data on data transmission.

**Notebook:** [manual_eod.ipynb](manual_eod.ipynb)   

This notebook demonstrates how to connect to the RDB cluster and manually run its end of day function. This notebook uses the pykx q magic cell to connect to and call the function on the remote cluster.

**Notebook:** [delete_all.ipynb](delete_all.ipynb)   

This notebook deletes all the resources created by the create_all notebook, effectively tearing down the application.

**Notebook:** [debugging.ipynb](debugging.ipynb)   

This notebook demonstrates a debugging setup to a remote cluster. Using the q magic from pykx one can connect to a remote cluster, define functions on the cluster and call those defined functions.

## q Files
All q files for this application are located in the [basictick](basictick) sub directory of this project.

## Python Files
[env.py](env.py) managed kdb Insights environment information including credentials,   
[basictick_setup.py](basictick_setup.py) application setup information including all resource names.   
[managed_kx.py](managed_kx.py) Utility functions to work with the FinSpace with Managed kdb Insights boto APIs.   

