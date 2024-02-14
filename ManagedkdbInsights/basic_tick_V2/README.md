# Setup of Basic Tick on Managed kdb Insights
This project demonstrates an implementation of a basic market data tick architecture using FinSpace Managed kdb Insights. 

# Architecture 
[Architecture of kdb+ systems](https://code.kx.com/q/architecture/)

## Managed kdb Insights Architecture 
<img src="Deepdive Diagrams-Architecture FinSpace.drawio.png"  width="50%">

# Implementation Outline

**Notebook:** [create_all.ipynb](create_all.ipynb)   
This notebook performs the following steps to setup and run all the kdb processes of this application.

1. Create and Populate a Database
2. Create a Scaling Group
3. Create a Shared Volume
4. Create a Dataview of the Database on the shared volume
5. Create Cluster: Tickerplant (TP)
6. Create Cluster: Historical Database (HDB)
7. Create Cluster: Gateway (GW)
8. Create Cluster: Realtime Database (RDB)
9. Start a FeedHandler (FH)

**Notebook:** [pykx_query_all.ipynb](pykx_query_all.ipynb)   

This notebook queries the HDB and RDB directly and compares their results with data queried through the gateway.

**Notebook:** [process_EOD.ipynb](process_EOD.ipynb)   

This notebook demonstrates and end of day (EOD) savedown of the RDB's collected data and adding that saved data to the database using a changeset.

**Notebook:** [pykx_clear_RDB.ipynb](pykx_clear_RDB.ipynb)   

This notebook demonstrates how to clear the RDB's in memory data.

**Notebook:** [get_connection_strings.ipynb](get_connection_strings.ipynb)   

This notebook returns all the connection strings to the Managed kdb processes created for this application.

**Notebook:** [delete_all.ipynb](delete_all.ipynb)   

This notebook deletes all the resources created by the create_all notebook, effectively tearing down the application.

## Python Files
[env.py](env.py) managed kdb Insights environment information including credentials,   
[basictick_setup.py](basictick_setup.py) application setup information including all resource names.   
[managed_kx.py](managed_kx.py) Utility functions to work with the FinSpace with Managed kdb Insights boto APIs.   

