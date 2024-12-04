# Amazon FinSpace Examples
This repository contains examples that show how to work with [Amazon FinSpace](https://aws.amazon.com/finspace/). 

## Managed kdb Insights
These are example projects using [FinSpace with Managed kdb Insights](ManagedkdbInsights). Refer to each project README.

- [Basic Tick V3](ManagedkdbInsights/basic_tick_V3)  
  - Market data collection and query application   
- [Boto Use Examples](ManagedkdbInsights/boto)  
  - Using boto python libraries to interact with the service   
- [dbmaint](ManagedkdbInsights/dbmaint)  
  - Performing DB maintenance on a FinSpace Managed database
- [HDB Backup](ManagedkdbInsights/hdb_backup)  
  - Backup an on-prem historical database into FinSpace
  - With backup in FinSpace, use FinSpace  clusters for on-demand compute for database query
- [CSV File Processing](ManagedkdbInsights/processing_data)  
  - Processing csv.gz files (such as from a data vendor) into a FinSpace Managed database
- [q Code Examples](ManagedkdbInsights/q)  
  - q library useful for interacting with FinSpace from external q applications (such as on-prem)
- [TorQ](ManagedkdbInsights/torq)  
  - Application using the open-source TorQ libraries
- [Update Cluster](ManagedkdbInsights/update_cluster)  
  - Updating a cluster with newer code (such as code being developed locally and running on managed clusters)   

## FAQ
*How do I contribute my own examples?*  

- Although we're extremely excited to receive contributions from the community, we're still working on the best mechanism to take in examples from external sources.  Please bear with us in the short-term if pull requests take longer than expected or are closed.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

