# Examples
- [Basic Tick V3](basic_tick_V3)  
  - Market data collection and query application   
- [Boto Use Examples](boto)  
  - Using boto python libraries to interact with the service   
- [dbmaint](dbmaint)  
  - Performing DB maintenance on a FinSpace Managed database
- [HDB Backup](hdb_backup)  
  - Backup an on-prem historical database into FinSpace
  - With backup in FinSpace, use FinSpace  clusters for on-demand compute for database query
- [CSV File Processing](processing_data)  
  - Processing csv.gz files (such as from a data vendor) into a FinSpace Managed database
- [q Code Examples](q)  
  - q library useful for interacting with FinSpace from external q applications (such as on-prem)
- [TorQ](torq)  
  - Application using the open-source TorQ libraries
- [Update Cluster](update_cluster)  
  - Updating a cluster with newer code (such as code being developed locally and running on managed clusters)   


## Running Examples
Examples all follow a common setup and each have a README file to expalin the example and code used.


### [env.py](env.py)
Sym linked to each example sub-directory, update this files with your specific environment information such as account ID, FinSpace environment ID, VPC ID, Security Sroup, availability zones. You will see these defined as empty strings from the repository.

### [env.r](env.r)
Sym linked to each example sub-directory, update this files with your specific environment information such as account ID, FinSpace environment ID, VPC ID, Security Sroup, availability zones. You will see these defined as empty strings from the repository.


### [managed_kx.py](managed_kx.py)
Sym linked to each example sub-directory. Used by all examples to help simplify and enhance the basic boto functions used in the examples.


### AWS Credentials
Be sure the notebook environment has the correct AWS credentials for the account you are using. Recomment you update the settings in ~/.aws/credentials with AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN. Most enterprise customers have a mechanism to vend and update these credentials.


# Directions
- env.py contains environment specific information, enter details of your environment
  - Your AWS Account ID for ACCOUNT_ID
  - Your FinSpace Managed kdb Insights Environment ID for ENV_ID
  - Your VPC ID for VPC_ID
- Do above at the "ManagedkdbInsights" folder level
- Sym link the env.py file into sub-directories, such as boto and basic_tick
- Modify notebooks to import the env.py file
  - with symlink, the file will be 'local' to the notebook

# Appendix

## Update requirements.txt
Generating an updated requirements.txt file.

```
pip freeze > ~/ManagedKdbInsights/requirements.txt
```

